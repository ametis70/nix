{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  boot.extraModprobeConfig = "options btusb enable_autosuspend=0";

  # Realtek RTL8761B chip (used by TP-Link UB500).
  hardware.firmware = [ pkgs.rtl8761b-firmware ];
}
