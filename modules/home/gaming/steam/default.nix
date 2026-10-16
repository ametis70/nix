{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.gaming.steam.returnToGamingMode;
in
{
  options.custom.gaming.steam.returnToGamingMode.enable =
    lib.mkEnableOption "Return to Gaming Mode desktop shortcut";

  config = lib.mkIf cfg.enable {
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
  };
}
