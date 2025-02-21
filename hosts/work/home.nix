{ pkgs, ... }:

{
  imports = [
    ../../modules/home/macos.nix
    ../../modules/home/kitty/kitty.nix
  ];

  programs.kitty.package = pkgs.emptyDirectory;

}
