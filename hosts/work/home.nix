{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/home/macos.nix
    ../../modules/home/dev.nix
    ../../modules/home/fonts/fonts.nix
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

  home.packages = with pkgs; [
    scrcpy
    android-tools
    pandoc
    wireguard-tools
  ];

  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: { inherit (tpkgs) scheme-small pgfopts beamertheme-metropolis; };
  };

  home.activation = {
    asdf-completion = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run rm -rf "''${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
      run mkdir -p "''${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
      run /opt/homebrew/bin/asdf completion zsh > "''${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
    '';
  };

  programs.kitty.font.size = 16;
  home.stateVersion = "24.11";
}
