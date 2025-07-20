{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.zsh;
in
{
  options = {
    custom.zsh = {
      enable = lib.mkEnableOption "zsh configuration" // {
        default = true;
      };
      enableZprof = lib.mkEnableOption "zsh profiling";
      initContentBefore = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Extra content to add at the very beginning of the zshrc.";
      };
      initContentBeforeCompInit = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Extra content to add before compinit (order 550).";
      };
      initContentAfter = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Extra content to add just before zprof at the very end of the zshrc.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
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
                ''if:'[[ "$AGENT_MODE" != "true" ]]' ''
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
        initContent = lib.mkMerge [
          (lib.mkBefore ''
            ${lib.optionalString cfg.enableZprof "zmodload zsh/zprof"}
            ${lib.optionalString cfg.enableZprof "typeset -g POWERLEVEL9K_INSTANT_PROMPT=off"}
            ${cfg.initContentBefore}
            # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
            # Initialization code that may require console input (password prompts, [y/n]
            # confirmations, etc.) must go above this block; everything else may go below.
            if [[ "$AGENT_MODE" != "true" ]] && [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
              source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
            fi

            export GPG_TTY=$TTY
          '')

          # Default priority
          ''
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
          ''

          (lib.mkOrder 550 ''
            ${cfg.initContentBeforeCompInit}
          '')

          (lib.mkAfter ''
            ${cfg.initContentAfter}
            ${lib.optionalString cfg.enableZprof "zprof"}
          '')
        ];
      };
    };
  };
}
