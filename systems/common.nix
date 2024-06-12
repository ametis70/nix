{ pkgs, specialArgs, ... }:

{
  imports = [ ../programs/nvim/nvim.nix ];

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home.username = specialArgs.host.username;

  home.packages = with pkgs; [
    timewarrior
    taskwarrior
    taskwarrior-tui
    pass
    fd
    (nerdfonts.override { fonts = [ "Iosevka" ]; })
  ];

  fonts.fontconfig.enable = true;

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      autosuggestion = {
        enable = true;
      };
    };
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
  };
}
