{ config, lib, ... }:

let
  cfg = config.custom.programs.wm.waybar;
in
{
  options.custom.programs.wm.waybar = {
    enable = lib.mkEnableOption "Enable Waybar status bar";
  };

  config = lib.mkIf cfg.enable {

    programs.waybar.enable = true;
    xdg.configFile."waybar/config.jsonc".source = ./config.jsonc;
    xdg.configFile."waybar/style.css".source = ./style.css;

    catppuccin.waybar.mode = "createLink";
  };
}
