{ config, lib, ... }:

let
  cfg = config.custom.hardware.gamepad."8bitdo-pro-3";
in
{
  options.custom.hardware.gamepad."8bitdo-pro-3".enable =
    lib.mkEnableOption "8BitDo Pro 3 receiver HID polling quirk";

  config = lib.mkIf cfg.enable {
    # 0x400 = HID_QUIRK_ALWAYS_POLL
    boot.extraModprobeConfig = ''
      options usbhid quirks=0x2dc8:0x3109:0x00000400,0x2dc8:0x310b:0x00000400
    '';
  };
}
