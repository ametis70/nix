{ pkgs, specialArgs, ... }:

{
  imports = [
    ./zsh
    ./k9s
    ./k3s-client
    ./catppuccin
  ];

  programs.home-manager.enable = true;

  home.username = specialArgs.host.username;

  home.packages = with pkgs; [
    pass
    fd
    curl
    jq
    ranger
    delta
  ];

  programs = {
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
    git = {
      enable = true;
    };
    delta = {
      enable = true;
      enableGitIntegration = true;
    };
    gpg = {
      enable = true;
    };
  };
}
