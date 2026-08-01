{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.custom.qmk;
in
{
  options.custom.qmk.enable = lib.mkEnableOption "QMK keyboard support (via configurator + udev)";

  # `via` is unfree; the host's allowUnfreePredicate must permit it.
  config = lib.mkIf cfg.enable {
    hardware.keyboard.qmk.enable = true;
    environment.systemPackages = [ pkgs.via ];
    services.udev.packages = [ pkgs.via ];
  };
}
