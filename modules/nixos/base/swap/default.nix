{ config, lib, ... }:

let
  cfg = config.custom.swap;
in
{
  options.custom.swap = {
    enable = lib.mkEnableOption "swap file";

    sizeGB = lib.mkOption {
      type = lib.types.ints.positive;
      default = 16;
      description = "Swap file size in GiB.";
    };
  };

  config = lib.mkIf cfg.enable {
    swapDevices = [
      {
        device = "/swapfile";
        size = cfg.sizeGB * 1024;
      }
    ];
  };
}
