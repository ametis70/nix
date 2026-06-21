{
  pkgs,
  specialArgs,
  lib,
  config,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../../modules/nixos/common.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/pipewire.nix

    ../../modules/nixos/user.nix
    ../../modules/nixos/bluetooth.nix
  ];

  networking = {
    hostName = specialArgs.host.hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };

  systemd.targets = {
    sleep.enable = true;
    suspend.enable = true;
    hibernate.enable = true;
    hybrid-sleep.enable = true;
  };

  # swapDevices = [
  #   {
  #     device = "/swapfile";
  #     size = 16 * 1024;
  #   }
  # ];

  nixpkgs.overlays = [
    (final: prev: {
      steamos-manager = prev.steamos-manager.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ./steamos-manager-jobmode-replace.patch
        ];
      });
    })
  ];

  # No KillMode override needed: switch_to_login_mode() writes the temp session file
  # (set_temporary_session) *before* calling logout() to stop graphical-session.target,
  # and with JobMode::Replace the write completes before any job races can occur.
  # Using the default KillMode=control-group avoids stale steamos-manager processes
  # that would otherwise accumulate across session switches with KillMode=none.

  # steamos-manager looks for session .desktop files under /usr/share/{wayland-sessions,xsessions}
  # (hardcoded paths). On NixOS these live in the nix store. Symlink them so that
  # steamos-manager's ValidDesktopSessions and SwitchToDesktopMode DBus methods work correctly.
  #
  # We also remove the [Autologin] Session= key from /etc/sddm.conf (via sddm.settings override)
  # and instead write the default autologin session to /etc/sddm.conf.d/zz-steamos-autologin.conf.
  # SDDM processes conf.d files before /etc/sddm.conf (which is appended last and wins), so
  # without this fix the temp-login conf (zzt-steamos-temp-login.conf) written by steamos-manager
  # is always overridden by the Session= in /etc/sddm.conf and SDDM never switches to the desktop.
  # With Session= removed from /etc/sddm.conf, the conf.d ordering is:
  #   zz-steamos-autologin.conf (default: gamescope-wayland)  <- lower priority
  #   zzt-steamos-temp-login.conf (set by steamos-manager)    <- wins on next autologin
  # Disable NixOS-managed autologin so that [Autologin] Session= is NOT written to /etc/sddm.conf.
  # SDDM processes conf.d files before /etc/sddm.conf (appended last), so any Session= in
  # /etc/sddm.conf would permanently override steamos-manager's zzt-steamos-temp-login.conf,
  # making "Switch to Desktop" always return to gamescope instead of launching plasma.
  #
  # Instead, we write the full autologin config to /etc/sddm.conf.d/zz-steamos-autologin.conf
  # via tmpfiles (create-if-missing), and steamos-manager manages its content from there.
  # The conf.d ordering is then:
  #   steamos.conf                   <- empty sentinel (steamos-manager session management)
  #   zz-steamos-autologin.conf      <- default: gamescope-wayland  (lower priority)
  #   zzt-steamos-temp-login.conf    <- set by steamos-manager on switch (higher priority)
  services.displayManager.autoLogin.enable = lib.mkForce false;
  # Keep Relogin and User so SDDM still autologins, driven from conf.d only.
  services.displayManager.sddm.settings.Autologin = {
    Relogin = true;
    User = "ametis70";
  };

  systemd.tmpfiles.rules =
    let
      desktops = config.services.displayManager.sessionData.desktops;
    in
    [
      "L+ /usr/share/wayland-sessions - - - - ${desktops}/share/wayland-sessions"
      "L+ /usr/share/xsessions - - - - ${desktops}/share/xsessions"
      # Create the default autologin conf that steamos-manager manages.
      # Use 'f' (create if missing, never overwrite) so steamos-manager can update it freely.
      "f /etc/sddm.conf.d/zz-steamos-autologin.conf 0644 root root - [Autologin]\\nSession=gamescope-wayland.desktop\\n"
    ];

  nixpkgs.config = {
    rocmSupport = true;

    allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-unwrapped"
        "steam-run"
        "steamdeck-hw-theme"
        "steam-jupiter-unwrapped"
      ];
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    ncpamixer
    edid-decode
    retroarch-joypad-autoconfig
    retroarch-assets
    retroarch-free
    kodi-wayland
    libcec
    moonlight-qt
    ungoogled-chromium

    protonup-ng
    mangohud
  ];

  users.users.ametis70.extraGroups = [ "dialout" ];

  # hardware.bluetooth = {
  #   enable = true;
  #   powerOnBoot = true;
  # };

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager = {
    defaultSession = lib.mkDefault "plasma";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      desktopSession = "plasma";
      user = "ametis70";
    };

    steamos = {
      useSteamOSConfig = true;
    };

    hardware.has.amd.gpu = true;
  };

  system.stateVersion = "25.11";
}
