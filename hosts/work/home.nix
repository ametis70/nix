{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/home/macos.nix
    ../../modules/home/dev.nix
    ../../modules/home/fonts/fonts.nix
    ../../modules/home/kitty/kitty.nix
    ../../modules/home/emacs/emacs.nix
    ../../modules/home/pdf/pdf.nix
    ../../modules/home/hypervisor-virt-manager/hvm.nix
  ];

  custom.zsh = {
    initContentBefore = ''
      if [[ -n "$npm_config_yes" ]] || [[ -n "$CI" ]] || [[ "$-" != *i* ]]; then
        export AGENT_MODE=true
      else
        export AGENT_MODE=false
      fi

      if [[ "$AGENT_MODE" == "true" ]]; then
        POWERLEVEL9K_INSTANT_PROMPT=off
        # Disable complex prompt features for AI agents
        POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
        POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
        # Ensure non-interactive mode
        export DEBIAN_FRONTEND=noninteractive
        export NONINTERACTIVE=1
      fi
    '';

    initContentBeforeCompInit = ''
      # asdf completion
      fpath=(''${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
    '';
    initContentAfter = ''
      # Homebrew
      PATH=$PATH:/opt/homebrew/bin

      # Go
      export GOPRIVATE=github.com/mercadolibre/*,github.com/melisource/*

      # Fury
      export RANGER_FURY_LOCATION="$HOME/.fury"
      export RANGER_FURY_VENV_LOCATION="$RANGER_FURY_LOCATION/fury_venv"
      declare FURY_BIN_LOCATION="$RANGER_FURY_VENV_LOCATION/bin"
      export PATH="$PATH:$FURY_BIN_LOCATION"

      # Nordic Doctor
      export NORDIC_DOCTOR_DIR="$HOME/.nordic-doctor"
      export PATH="$NORDIC_DOCTOR_DIR/bin:$PATH"

      # asdf
      export PATH="''${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

      if [[ "$AGENT_MODE" == "true" ]]; then
        PROMPT='%n@%m:%~%# '
        RPROMPT=""
        unsetopt CORRECT
        unsetopt CORRECT_ALL
        setopt NO_BEEP
        setopt NO_HIST_BEEP  
        setopt NO_LIST_BEEP
        
        # Agent-friendly aliases to avoid interactive prompts
        alias npm='npm --no-fund --no-audit'
        alias yarn='yarn --non-interactive'
        alias pip='pip --quiet'
        alias git='git -c advice.detachedHead=false'
      fi
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
    pre-commit
    qemu
  ];

  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {
      inherit (tpkgs)
        latexmk
        biber
        scheme-small
        pgfopts
        beamertheme-metropolis
        ;
    };
  };

  home.activation = {
    asdf-completion = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run rm -rf "''${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
      run mkdir -p "''${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
      run /opt/homebrew/bin/asdf completion zsh > "''${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
    '';
  };

  programs.git.extraConfig = {
    commit = {
      gpgsign = true;
    };
    user = {
      signingkey = "~/.ssh/id_ed25519_melisource.pub";
    };
    gpg = {
      format = "ssh";
    };
  };

  custom.k3s-client.enable = true;

  programs.kitty.font.size = 16;

  home.stateVersion = "24.11";
}
