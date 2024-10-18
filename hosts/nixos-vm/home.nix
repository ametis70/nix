{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/home/nixos.nix
    ../../modules/home/discord/discord.nix
    ../../modules/home/kitty/kitty.nix
    ../../modules/home/hyprland/hyprland.nix
    ../../modules/home/waybar/waybar.nix
    ../../modules/home/wofi/wofi.nix
  ];

  home.packages = with pkgs; [
    ungoogled-chromium
    telegram-desktop
  ];

  home.pointerCursor = {
    name = "phinger-cursors-light";
    package = pkgs.phinger-cursors;
    size = 32;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  wayland.windowManager.hyprland.settings = {
    monitor = "HDMI-A-1, 2560x1440@143.98, 0x0, 1";
  };
}
