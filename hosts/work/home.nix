{ pkgs, lib, ... }:

{
  custom = {
    development = {
      nvim.enable = true;
      opencode.enable = true;
      pi.enable = true;
      emacs.enable = true;
      lang = {
        go.enable = true;
        javascript.enable = true;
        python.enable = true;
      };
    };
    desktop.fonts.enable = true;
    hypervisor.client.enable = true;
    homelab.client.enable = true;
    programs = {
      terminal.enable = true;
      media.editing.pdf.enable = true;
      cli.zk.enable = true;
    };

    shell.zsh = {
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
        export PATH=$PATH:/opt/homebrew/bin

        # Claude
        export PATH=$PATH:~/.local/bin

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
  };

  home.sessionVariables = {
    OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";
    OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
  };

  home.packages = with pkgs; [
    pnpm
    scrcpy
    android-tools
    pandoc
    wireguard-tools
    pre-commit
    qemu
    rclone
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

  programs.lazygit.settings = {
    overrideGpg = true;
  };

  programs.git = {
    enable = true;
    settings = {
      commit = {
        gpgsign = true;
      };
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
      user = {
        signingkey = "~/.ssh/id_ed25519_melisource.pub";
      };
      gpg = {
        format = "ssh";
      };
    };
  };

  programs.kitty.font.size = 17;

  home.stateVersion = "24.11";
}
