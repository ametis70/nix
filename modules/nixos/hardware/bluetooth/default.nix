{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.hardware.bluetooth;
in
{
  options.custom.hardware.bluetooth = {
    enable = lib.mkEnableOption "Enable Bluetooth support";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    boot.extraModprobeConfig = "options btusb enable_autosuspend=0";

    # Realtek RTL8761B chip (used by TP-Link UB500).
    hardware.firmware = [ pkgs.rtl8761b-firmware ];
  };
}
