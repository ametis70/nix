{ pkgs, ... }:

{
  imports = [
    ../../modules/home/nixos.nix
    ../../modules/home/dev.nix
    ../../modules/home/kitty/kitty.nix
    ../../modules/home/fonts/fonts.nix
    ../../modules/home/hypervisor-virt-manager/hvm.nix
  ];

  home.packages = with pkgs; [
    darktable
    art
    exiftool
    hdrmerge

    discord
    telegram-desktop

    pinentry-qt

    pi-coding-agent

    mpv

    blender

    krita
    xournalpp
  ];

  custom.k3s-client.enable = true;

  home.stateVersion = "25.11";
}
