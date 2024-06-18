{ pkgs, specialArgs, ... }:

{
  imports = [
    ../programs/nvim/nvim.nix
    ../programs/zsh/zsh.nix
  ];

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home.username = specialArgs.host.username;

  home.packages = with pkgs; [
    timewarrior
    taskwarrior
    taskwarrior-tui
    pass
    fd
    curl
    asdf-vm
    (nerdfonts.override { fonts = [ "Iosevka" ]; })
  ];

  fonts.fontconfig.enable = true;

  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
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
  };
}
