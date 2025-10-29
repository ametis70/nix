{ pkgs, specialArgs, ... }:

{
  imports = [ ./common.nix ];

  home.homeDirectory = "/home/${specialArgs.host.username}";

  home.packages = with pkgs; [
    pinentry-curses
    xclip
    wl-clipboard
  ];
}
