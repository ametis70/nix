{ pkgs, specialArgs, ... }:

{
  imports = [ ./common.nix, ./generic.nix ];

  home.homeDirectory = "/Users/${specialArgs.host.username}";

  home.packages = with pkgs; [
    pngpaste
  ];
}
