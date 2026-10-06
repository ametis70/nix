{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.programs.wm.dunst;
in
{
  options.custom.programs.wm.dunst = {
    enable = lib.mkEnableOption "Enable Dunst notification daemon";
  };

  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      settings = {
        global = {
          width = 400;
          gap_size = 6;
          padding = 12;
          offset = "12x6";
          origin = "top-right";
          font = "Iosevka Medium 14";
        };
      };
    };
  };
}
