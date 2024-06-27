{ pkgs, ... }:

{
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      autosuggestion = {
        enable = true;
      };
      syntaxHighlighting = {
        enable = true;
      };
      zplug = {
        enable = true;
        plugins = [
          { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
          { name = "Aloxaf/fzf-tab"; }
        ];
      };
      plugins = [
        {
          name = "powerlevel10k-config";
          src = ./p10k;
          file = "p10k.zsh";
        }
      ];
      initExtraFirst = ''
        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi

        # Source asdf
        . "${pkgs.lib.getBin pkgs.asdf-vm}/share/asdf-vm/asdf.sh"

        export GPG_TTY=$TTY
      '';
      initExtraBeforeCompInit = ''
        # asdf completion
        fpath=(''${ASDF_DIR}/completions $fpath)
      '';
      initExtra = ''
        bindkey "^[[3~"   delete-char
        bindkey "^[[5~"   beginning-of-buffer-or-history
        bindkey "^[[6~"   end-of-buffer-or-history
        bindkey "^[[H"    beginning-of-line
        bindkey "^[[F"    end-of-line
        bindkey '^[[1;5C' forward-word
        bindkey '^[[1;5D' backward-word
      '';
    };
  };
}
