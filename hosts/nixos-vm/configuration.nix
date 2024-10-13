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

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
  ];

  environment.systemPackages = with pkgs; [
    dunst
    xdg-desktop-portal-hyprland
    kdePackages.polkit-kde-agent-1

    wofi
    waybar
    pavucontrol
    wl-clipboard
    ungoogled-chromium
    telegram-desktop
    discord
    pasystray
    networkmanagerapplet
    hyprpaper
    slurp
    grim
    qt6ct
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
