{ lib, config, ... }:

let
  cfg = config.custom.catppuccin;
in
{
  options.custom.catppuccin.enable =
    lib.mkEnableOption "Catppuccin theming for home programs"
    // {
      default = true;
    };

  config = lib.mkIf cfg.enable {
    catppuccin = {
      enable = true;
      flavor = "mocha";
    };

    catppuccin.nvim.enable = false;
    catppuccin.gtk.icon.enable = false;
    catppuccin.kvantum.enable = false;
  };
}
