{
  pkgs,
  config,
  specialArgs,
  lib,
  ...
}:

let
  # steamos-session-select wrapper: intercepts Steam's "Switch to Desktop" / "Return to Gaming"
  # and routes them through the launchscope API instead of SDDM session switching.
  steamos-session-wrapper = pkgs.writeShellScriptBin "steamos-session-select" ''
    # Stop the Jovian gamescope-session target.
    # This causes start-gamescope-session to exit naturally (its --wait returns),
    # which launchscoped detects and uses to relaunch the launcher UI.
    systemctl --user stop gamescope-session.target 2>/dev/null || true
  '';
in
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../../modules/nixos/common.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/user.nix
    ../../modules/nixos/pipewire.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/emulation

    ./edid
  ];

  networking = {
    hostName = specialArgs.host.hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];

  nixpkgs.config = {
    allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) (
        [
          "steam"
          "steam-original"
          "steam-unwrapped"
          "steam-run"
          "steamdeck-hw-theme"
          "steam-jupiter-unwrapped"
        ]
        ++ config.custom.emulation.allowedUnfreePackages
      );
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
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

    steamos-session-wrapper
  ];

  users.users.ametis70.extraGroups = [
    "dialout"
    "seat"
  ];

  services.seatd = {
    enable = true;
    group = "seat";
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = false;

  programs.steam.enable = true;
  jovian.steam = {
    enable = true;
    autoStart = false;
    user = "ametis70";
  };

  # Disable Jovian's CEC integration — it uses inputattach/cecd which conflict
  # with libcec's direct port access needed for the Pulse-Eight USB adapter.
  jovian.steamos.enableHdmiCecIntegration = false;

  services.launchscope = {
    enable = true;
    user = "ametis70";
    autologin = {
      enable = true;
      tty = "tty1";
    };
    cec = {
      enable = true;
      adapterDevice = "ttyACM0";
      tvDevice = 0;
      avrDevice = 5;
      avrPort = 1;
      sourceAddr = "1.6.0.0";
      activateDelay = 2.0;
    };
  };

  custom.services.nfs.enable = true;

  system.stateVersion = "25.05";
}
