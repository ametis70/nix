{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ./edid
  ];

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
      hasAvr = true;
      sourceAddr = "1.6.0.0";
    };
  };

  custom = {
    networking.networkmanager.enable = true;
    swap = {
      enable = true;
      sizeGB = 16;
    };
    desktop = {
      de.plasma.enable = true;
      dm.sddm.enable = false;
    };
    gaming = {
      emulation.enable = true;
      streaming.moonlight.enable = true;
      steam = {
        enable = true;
        jovian = {
          enable = true;
          autoStart = false;
          sessionWrapper = true;
        };
      };
    };
    services = {
      pipewire.enable = true;
      seatd.enable = true;
    };
    hardware = {
      bluetooth.enable = true;
      cec.enable = true;
      intel.graphics.enable = true;
      gamepad = {
        "8bitdo-pro-3".enable = true;
        steam-puck-bridge.enable = true;
      };
    };
    homelab.nfs.client.enable = true;
  };

  # Jovian CEC conflicts with libcec's direct Pulse-Eight adapter access.
  jovian.steamos.enableHdmiCecIntegration = false;

  system.stateVersion = "25.05";
}
