{ pkgs, ... }:

{
  imports = [
    ../../modules/home/nixos.nix
    ../../modules/home/discord/discord.nix
    ../../modules/home/kitty/kitty.nix
    ../../modules/home/hyprland/hyprland.nix
    ../../modules/home/hyprland/hyprland-deck.nix
    ../../modules/home/design/design.nix
    ../../modules/home/zathura/zathura.nix
    ../../modules/home/gpg-agent/gpg-agent.nix
  ];

  home.packages = with pkgs; [
    ungoogled-chromium
    telegram-desktop
    nautilus
    cbatticon
  ];

  wayland.windowManager.hyprland = {
    settings = {
      exec-once = [
        "steam"
        "cbatticon"
      ];
    };
  };

  home.stateVersion = "24.11";
}
