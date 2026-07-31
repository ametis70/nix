{ lib, config, ... }:

let
  cfg = config.custom.plasma;
in
{
  options.custom.plasma.enable = lib.mkEnableOption "KDE Plasma 6 desktop (SDDM)";

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
  };
}
