{ config, lib, ... }:

let
  cfg = config.custom.bootloader.systemd-boot;
in
{
  options = {
    custom.bootloader.systemd-boot.enable = lib.mkOption {
      description = "Enable systemd-boot";
      default = true;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      efi.canTouchEfiVariables = lib.mkDefault true;
      systemd-boot.enable = lib.mkDefault true;
    };
  };
}
