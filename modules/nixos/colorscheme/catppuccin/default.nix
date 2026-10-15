{
  lib,
  config,
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
    }
    // lib.optionalAttrs (lib.hasAttrByPath [ "catppuccin" "autoEnable" ] options) {
      autoEnable = true;
    };
  };
}
