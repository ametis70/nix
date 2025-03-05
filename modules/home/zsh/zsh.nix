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
          {
            name = "romkatv/powerlevel10k";
            tags = [
              "as:theme"
              "depth:1"
            ];
          }
          { name = "jeffreytse/zsh-vi-mode"; }
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

        export GPG_TTY=$TTY
      '';
      initExtra = ''
        function after_zvm_init() {
          source <(fzf --zsh)
          source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

          bindkey "^[[3~"   delete-char
          bindkey "^[[5~"   beginning-of-buffer-or-history
          bindkey "^[[6~"   end-of-buffer-or-history
          bindkey "^[[H"    beginning-of-line
          bindkey "^[[F"    end-of-line
          bindkey '^[[1;5C' forward-word
          bindkey '^[[1;5D' backward-word
        }

        zvm_after_init_commands+=(after_zvm_init)

        ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      '';
    };
  };
}
