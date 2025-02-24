{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/home/macos.nix
    ../../modules/home/kitty/kitty.nix
  ];

  programs.kitty.package = pkgs.emptyDirectory;

  programs.zsh.initExtra = lib.mkAfter ''
    PATH=$PATH:/opt/homebrew/bin
  '';

  home.stateVersion = "24.11";
}
