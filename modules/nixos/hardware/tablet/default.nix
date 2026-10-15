{
  lib,
  config,
  ...
}:

let
  cfg = config.custom.hardware.tablet;
in
{
  options.custom.hardware.tablet = {
    enable = lib.mkEnableOption "Enable tablet drivers";
  };

  config = lib.mkIf cfg.enable {
    hardware.opentabletdriver.enable = true;
  };
}
