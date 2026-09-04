{ pkgs, ... }:

{
  imports = [
    ../../modules/home/nixos.nix
    ../../modules/home/dev.nix
    ../../modules/home/kitty/kitty.nix
    ../../modules/home/fonts/fonts.nix
  ];

  home.packages = with pkgs; [
    darktable
    art
    exiftool
    hdrmerge

    discord
    telegram-desktop

    mpv

    krita
    xournalpp
  ];

  home.stateVersion = "25.11";
}
