{ pkgs, specialArgs, ... }:

{
  imports = [ ./common.nix ];

  home.homeDirectory = "/Users/${specialArgs.host.username}";

  home.packages = with pkgs; [
    pinentry_mac
    pngpaste
  ];
}
