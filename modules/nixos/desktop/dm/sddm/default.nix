{ config, lib, ... }:

let
  cfg = config.custom.desktop.dm.sddm;
in
{
  options.custom.desktop.dm.sddm = {
    enable = lib.mkEnableOption "Use SDDM display manager";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };
}
