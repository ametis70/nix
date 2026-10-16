{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

  ];

  custom = {
    networking.networkmanager.enable = false;
    development.docker.enable = true;
    swap = {
      enable = true;
      sizeGB = 16;
    };
    homelab.nut = {
      enable = true;
      delay = 1;
      isVm = true;
      role = "client";
    };
  };

  system.stateVersion = "25.05";
}
