{ lib, config, ... }:

let
  cfg = config.custom.waybar;
in
{
  options.custom.waybar.enable = lib.mkEnableOption "waybar status bar";

  config = lib.mkIf cfg.enable {
    programs.waybar.enable = true;
    xdg.configFile."waybar/config.jsonc".source = ./config.jsonc;
    xdg.configFile."waybar/style.css".source = ./style.css;

    catppuccin.waybar.mode = "createLink";
  };
}
