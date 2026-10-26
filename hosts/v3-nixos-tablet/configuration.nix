{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  custom = {
    swap = {
      enable = true;
      sizeGB = 16;
    };
    timezone.dynamic = true;
    networking.networkmanager.enable = true;
    power = {
      sleep.enable = true;
      power-profiles-daemon.enable = true;
    };
    hardware = {
      amd.gpu.enable = true;
      bluetooth.enable = true;
      logitech.enable = true;
      m-vave.enable = true;
      tablet.enable = true;
    };
    desktop = {
      de.plasma.enable = true;
      dm.sddm.enable = true;
    };
    gaming = {
      steam = {
        enable = true;
        jovian = {
          enable = true;
          autoStart = false;
        };
      };
    };
    programs.chat.discord.enable = true;
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
    ryzenadj
  ];

  system.stateVersion = "25.11";
}
