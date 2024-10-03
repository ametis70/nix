{ config, lib, pkgs, specialArgs, ... }:

{
  imports = [
    ../../modules/nixos/common.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/user.nix
    ../../modules/nixos/guest.nix

    ./hardware-configuration.nix
  ];

  networking = {
    hostName = specialArgs.host.hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    dunst
    kitty
    xdg-desktop-portal-hyprland
    kdePackages.polkit-kde-agent-1
  ];

  security.polkit.enable = true;
  programs.hyprland.enable = true;
}

