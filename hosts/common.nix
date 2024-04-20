{ pkgs, ... }: {
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    timewarrior
    taskwarrior
    taskwarrior-tui
  ];
}
