{
  lib,
  pkgs,
  specialArgs,
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
  imports = [
    ./zsh
    ./k9s
    ./k3s-client
    ./catppuccin
  ];

  config = lib.mkMerge [
    {

      home.username = specialArgs.host.username;

      home.packages = with pkgs; [
        fd
        curl
        jq
        ranger
        delta
        wol
        rbw
        git
      ];

      programs = {
        home-manager.enable = true;
        fzf = {
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
        bat = {
          enable = true;
        };
        lazygit = {
          enable = true;
        };
        direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv = {
            enable = true;
          };
        };
      };
    }
    (lib.optionalAttrs (hmHas [
      "programs"
      "delta"
    ]) deltaUnstableConfig)
  ];
}
