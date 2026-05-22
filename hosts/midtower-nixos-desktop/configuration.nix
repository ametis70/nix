{
  pkgs,
  specialArgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../../modules/nixos/common.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/user.nix
  ];

  networking = {
    hostName = specialArgs.host.hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };

  # swapDevices = [
  #   {
  #     device = "/swapfile";
  #     size = 16 * 1024;
  #   }
  # ];

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
