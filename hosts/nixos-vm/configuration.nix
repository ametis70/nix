{ config, lib, pkgs, specialArgs, ... }:

{
  imports = [
    ../../modules/nixos/common.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/user.nix
    ../../modules/nixos/guest.nix

    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
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
    xdg-desktop-portal-hyprland
    kdePackages.polkit-kde-agent-1
  ];

  fonts.packages = with pkgs; [
    iosevka
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];

  security.polkit.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.hyprland.enable = true;
  services.xserver.exportConfiguration = true;
}
