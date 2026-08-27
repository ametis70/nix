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

  system.stateVersion = "25.11";
}
