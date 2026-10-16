{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.hardware.keyboard.sofle;
in
{
  options.custom.hardware.keyboard.sofle.enable = lib.mkEnableOption "Sofle keyboard QMK/VIA support";

  config = lib.mkIf cfg.enable {
    hardware.keyboard.qmk.enable = true;

    environment.systemPackages = [ pkgs.via ];
    services.udev.packages = [ pkgs.via ];

    # Hide the Sofle System Control USB interface from joystick applications.
    services.udev.extraRules = ''
      SUBSYSTEM=="input", \
        ENV{ID_VENDOR_ID}=="fc32", \
        ENV{ID_MODEL_ID}=="0287", \
        ENV{ID_USB_INTERFACE_NUM}=="02", \
        ENV{ID_INPUT_JOYSTICK}="", \
        ENV{ID_INPUT}="1", \
        ENV{ID_INPUT_KEY}="1"
    '';
  };
}
