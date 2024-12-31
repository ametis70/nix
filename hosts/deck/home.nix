{ pkgs, lib, ... }:

let
in
{
  imports = [
    ../../modules/home/linux.nix
    ../../modules/home/discord/discord.nix
    ../../modules/home/kitty/kitty.nix
    ../../modules/home/hyprland/hyprland.nix
    ../../modules/home/hyprland/hyprland-deck.nix
    ../../modules/home/design/design.nix
    ../../modules/home/zathura/zathura.nix
    ../../modules/home/gpg-agent/gpg-agent.nix
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "imagescan-plugin-networkscan"
    ];

  home.packages = with pkgs; [
    nixgl.nixGLIntel
    nixgl.nixVulkanIntel
    ungoogled-chromium
    telegram-desktop
    nautilus
  ];
}
