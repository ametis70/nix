{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.custom.programs.chat.telegram;
in
{
  options.custom.programs.chat.telegram = {
    enable = lib.mkEnableOption "Enable Telegram client";
  };

  config = lib.mkMerge [
    {
      custom.programs.chat.telegram.enable = lib.mkDefault config.custom.programs.chat.enable;
    }
    (lib.mkIf cfg.enable {
      home.packages = [ pkgs.telegram-desktop ];
    })
  ];
}
