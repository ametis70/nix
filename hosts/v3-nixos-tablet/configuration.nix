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

  time.timeZone = null;
  location.provider = "geoclue2";
  services.geoclue2 = {
    enable = true;
  };
  services.automatic-timezoned.enable = true;

  programs.ssh.startAgent = true;
  security.pam.services.login.kwallet.enable = true;
  security.pam.services.kde.kwallet.enable = true;

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

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    amdgpu = {
      initrd.enable = true;
    };
  };

  hardware.sensor.iio.enable = true;

  hardware.firmware = with pkgs; [
    alsa-firmware
  ];

  hardware.alsa.enablePersistence = true;

  environment.systemPackages = with pkgs; [
    ungoogled-chromium
    alsa-utils

    ryzenadj

    kdePackages.kwalletmanager
    kdePackages.ksshaskpass

    protonup-ng
    mangohud
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager = {
    defaultSession = lib.mkDefault "plasma";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  hardware.opentabletdriver.enable = true;

  programs = {
    gamemode = {
      enable = true;
    };
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
      "steamdeck-hw-theme"
      "steam-jupiter-unwrapped"
      "discord"
      "discord-unwrapped"
    ];

  services.power-profiles-daemon.enable = true;

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  jovian = {
    steam = {
      enable = true;
      autoStart = false;
      user = "ametis70";
    };

    hardware.has.amd.gpu = true;
  };

  programs.ssh = {
    askPassword = pkgs.lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
    enableAskPassword = true;
  };

  environment = {
    sessionVariables = {
      SSH_ASKPASS_REQUIRE = "prefer";
    };
  };

  system.stateVersion = "25.11";
}
