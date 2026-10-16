{
  lib,
  config,
  ...
}:

let
  cfg = config.custom.hardware.logitech;
in
{
  options.custom.hardware.logitech = {
    enable = lib.mkEnableOption "Enable Logitech wireless hardware support";
  };

  config = lib.mkIf cfg.enable {
    hardware.logitech.wireless = {
      enable = true;
    };
    programs.solaar.enable = true;
  };
}
