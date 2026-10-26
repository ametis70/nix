{ lib, config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./edid
  ];

  custom = {
    networking.networkmanager.enable = true;

    development.docker.enable = true;

    desktop = {
      dm.greetd.enable = true;
      wm.hyprland.enable = true;
    };

    gaming.emulation.enable = true;

    hardware = {
      bluetooth.enable = true;
      logitech.enable = true;
      m-vave.enable = true;
      keyboard.sofle.enable = true;
      tablet.enable = true;
    };

    services = {
      pipewire.enable = true;
      vm.guest.enable = true;
    };

    swap = {
      enable = true;
      sizeGB = 12;
    };

    homelab.nfs.client.enable = true;
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "discord-unwrapped"
      "imagescan-plugin-networkscan"
      "via"
    ];

  # Enable audio group for MIDI access
  users.users.ametis70.extraGroups = [ "audio" ];

  services.blueman.enable = true;

  system.stateVersion = "24.11";
}
