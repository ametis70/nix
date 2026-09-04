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

  environment.systemPackages = with pkgs; [
    ungoogled-chromium
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
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
    gamemode = {
      enable = true;

    };
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
      "discord"
    ];

  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;

    settings = {
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_SAV = "power";

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_BOOST_ON_SAV = 0;

      RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
      RADEON_DPM_PERF_LEVEL_ON_BAT = "auto";
      RADEON_DPM_PERF_LEVEL_ON_SAV = "low";

      AMDGPU_ABM_LEVEL_ON_AC = 0;
      AMDGPU_ABM_LEVEL_ON_BAT = 3;
      AMDGPU_ABM_LEVEL_ON_SAV = 3;
    };
  };

  system.stateVersion = "25.11";
}
