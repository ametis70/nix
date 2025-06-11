{ pkgs, specialArgs, ... }:

{
  imports = [
    ./zsh/zsh.nix
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
      colors = {
        "bg+" = "#2e3c64";
        bg = "#1f2335";
        border = "#29a4bd";
        fg = "#c0caf5";
        gutter = "#1f2335";
        header = "#ff9e64";
        "hl+" = "#2ac3de";
        hl = "#2ac3de";
        info = "#545c7e";
        marker = "#ff007c";
        pointer = "#ff007c";
        prompt = "#2ac3de";
        query = "#c0caf5";
        scrollbar = "#29a4bd";
        separator = "#ff9e64";
        spinner = "#ff007c";
      };
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
      delta = {
        enable = true;
      };
    };
    gpg = {
      enable = true;
    };
  };
}
