{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  custom = {
    networking.networkmanager.enable = true;

    desktop.de.plasma.enable = true;

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
        rocm.enable = true;
      };
      bluetooth.enable = true;
      cec.enable = true;
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

  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
  };

  system.stateVersion = "25.11";
}
