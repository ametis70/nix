{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/home/macos.nix
    ../../modules/home/kitty/kitty.nix
  ];

  programs.kitty.package = pkgs.emptyDirectory;

  programs.zsh.initExtra = lib.mkAfter ''
    # Homebrew
    PATH=$PATH:/opt/homebrew/bin

    # Fury
    export RANGER_FURY_LOCATION="$HOME/.fury"
    export RANGER_FURY_VENV_LOCATION="$RANGER_FURY_LOCATION/fury_venv"
    declare FURY_BIN_LOCATION="$RANGER_FURY_VENV_LOCATION/bin"
    export PATH="$PATH:$FURY_BIN_LOCATION"
  '';

  home.stateVersion = "24.11";
}
