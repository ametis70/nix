{ lib, config, ... }:

let
  cfg = config.custom.bluetooth;
in
{
  options.custom.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth";
    powerOnBoot = lib.mkEnableOption "powering the Bluetooth controller on at boot";
    blueman = lib.mkEnableOption "the blueman applet";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    # Only override the NixOS default when explicitly requested, to stay neutral
    # for hosts that relied on the default.
    hardware.bluetooth.powerOnBoot = lib.mkIf cfg.powerOnBoot true;
    services.blueman.enable = lib.mkIf cfg.blueman true;
  };
}
