{ pkgs, specialArgs, ... }:

{
  imports = [ ./common.nix ];

  home.homeDirectory = "/home/${specialArgs.host.username}";

  home.packages = with pkgs; [
    pinentry_curses
    xclip
    wl-clipboard
  ];
}
