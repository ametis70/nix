{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/home/macos.nix
    ../../modules/home/kitty/kitty.nix
  ];

  programs.kitty.package = pkgs.emptyDirectory;

  programs.zsh = {
    initExtraBeforeCompInit = lib.mkAfter ''
      # asdf completion
      fpath=(''${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
    '';

    initExtra = lib.mkAfter ''
      # Homebrew
      PATH=$PATH:/opt/homebrew/bin

      # Fury
      export RANGER_FURY_LOCATION="$HOME/.fury"
      export RANGER_FURY_VENV_LOCATION="$RANGER_FURY_LOCATION/fury_venv"
      declare FURY_BIN_LOCATION="$RANGER_FURY_VENV_LOCATION/bin"
      export PATH="$PATH:$FURY_BIN_LOCATION"

      # asdf
      export PATH="''${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
    '';
  };

  programs.git.extraConfig = {
    url = {
      "ssh://git@github.com/" = {
        insteadOf = "https://github.com/";
      };
    };
  };

  home.stateVersion = "24.11";
}
