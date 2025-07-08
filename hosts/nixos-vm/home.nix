{ pkgs, ... }:

{
  imports = [
    ../../modules/home/nixos.nix
    ../../modules/home/dev.nix
    ../../modules/home/discord/discord.nix
    ../../modules/home/kitty/kitty.nix
    ../../modules/home/hyprland/hyprland.nix
    ../../modules/home/design/design.nix
    ../../modules/home/zathura/zathura.nix
    ../../modules/home/gpg-agent/gpg-agent.nix
    ../../modules/home/hypervisor-virt-manager/hvm.nix
    ../../modules/home/gnome-keyring
    ../../modules/home/pdf/pdf.nix
    ../../modules/home/k9s
  ];

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
