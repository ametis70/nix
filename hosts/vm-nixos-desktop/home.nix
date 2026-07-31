{ pkgs, ... }:

{
  imports = [
    ../../modules/home/hyprland/hyprland.nix
    ../../modules/home/design/design.nix
  ];

  custom.dev.enable = true;
  custom.gnome-keyring.enable = true;
  custom.video.enable = true;
  custom.discord.enable = true;
  custom.zathura.enable = true;
  custom.pdf.enable = true;
  custom.kitty.enable = true;
  custom.hvm.enable = true;

  home.packages = with pkgs; [
    ungoogled-chromium
    telegram-desktop
    nautilus
    file-roller
  ];

  wayland.windowManager.hyprland.settings = {
    monitor = "HDMI-A-1, 2560x1440@143.98, 0x0, 1";
  };

  custom.k3s-client.enable = true;

  home.stateVersion = "24.11";
}
