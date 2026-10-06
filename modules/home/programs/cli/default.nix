{
  pkgs,
  lib,
  options,
  ...
}:

let
  deltaUnstableConfig = {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };
  };

  hmHas = path: lib.hasAttrByPath path options;
in
{
  imports = [ ./zk ];
  config = lib.mkMerge [
    {
      home.packages = with pkgs; [
        fd
        curl
        ranger
        wol
        rbw
        git
        rsync
        openssl
        ncdu
        pwgen
      ];

      programs = {
        jq.enable = true;
        bat.enable = true;
        lazygit.enable = true;
        fzf = {
          enableNushellIntegration = false;
          enable = true;
          enableZshIntegration = true;
          defaultOptions = [
            "--highlight-line"
            "--info=inline-right"
            "--ansi"
            "--layout=reverse"
            "--border=none"
          ];
        };
        direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv = {
            enable = true;
          };
        };
        tmux = {
          enable = true;
          mouse = true;
          prefix = "C-a";
          keyMode = "vi";
          historyLimit = 5000;
          baseIndex = 1;
          terminal = "tmux-256color";
          extraConfig = ''
            set-option -g set-clipboard on
            set-option -g extended-keys on
            set-option -g extended-keys-format csi-u
            set-option -as terminal-features ",*:extkeys"
            set-option -as terminal-overrides ",*:Tc"
          '';
        };
      };
    }
    (lib.optionalAttrs (hmHas [
      "programs"
      "delta"
    ]) deltaUnstableConfig)
  ];
}
