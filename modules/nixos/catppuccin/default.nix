{ lib, config, ... }:

let
  cfg = config.custom.catppuccin;
in
{
  options.custom.catppuccin.enable = lib.mkEnableOption "Catppuccin theming for the system" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    catppuccin = {
      enable = true;
      flavor = "mocha";
    };
  };
}
