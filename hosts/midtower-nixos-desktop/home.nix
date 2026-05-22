{ pkgs, ... }:

{
  imports = [
    ../../modules/home/nixos.nix
    ../../modules/home/dev.nix
    ../../modules/home/kitty/kitty.nix
  ];

  home.file."Desktop/Return-to-Gaming-Mode.desktop".source =
    (pkgs.makeDesktopItem {
      desktopName = "Return to Gaming Mode";
      exec = "steamosctl switch-to-game-mode";
      icon = "steam";
      name = "Return-to-Gaming-Mode";
      startupNotify = false;
      terminal = false;
      type = "Application";
    })
    + "/share/applications/Return-to-Gaming-Mode.desktop";

  home.stateVersion = "25.11";
}
