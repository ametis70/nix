{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ./specialisations/k3s-agent
  ];

  custom = {
    networking.networkmanager.enable = true;

    desktop.de.plasma.enable = true;

    programs = {
      chat.discord.enable = true;
    };

    gaming = {
      emulation.enable = true;
      streaming.moonlight.enable = true;
      steam = {
        enable = true;
        jovian = {
          enable = true;
          autoStart = true;
        };
      };
    };

    hardware = {
      amd.gpu = {
        enable = true;
      };
      bluetooth.enable = true;
      logitech.enable = true;
      tablet.enable = true;
    };

    power = {
      sleep.enable = true;
    };

    services.pipewire.enable = true;

    swap = {
      enable = true;
      sizeGB = 16;
    };

    homelab.nfs.client.enable = true;
  };

  system.stateVersion = "25.11";
}
