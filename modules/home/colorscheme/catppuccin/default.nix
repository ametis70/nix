{
  config,
  lib,
  options,
  ...
}:

let
  cfg = config.custom.catppuccin;
in
{
  options.custom.catppuccin = {
    enable = lib.mkOption {
      description = "Enable catppuccin colorscheme";
      default = true;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    catppuccin = {
      enable = true;
      flavor = "mocha";

      nvim.enable = false;
      gtk.icon.enable = false;
      kvantum.enable = false;
      hyprland.enable = false;
    }

    // lib.optionalAttrs (lib.hasAttrByPath [ "catppuccin" "autoEnable" ] options) {
      autoEnable = true;
    };
  };
}
