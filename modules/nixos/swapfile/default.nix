{ lib, config, ... }:

let
  cfg = config.custom.swapfile;
in
{
  options.custom.swapfile = {
    enable = lib.mkEnableOption "a /swapfile";
    size = lib.mkOption {
      type = lib.types.int;
      default = 16 * 1024;
      description = "Swapfile size in MiB.";
    };
  };

  config = lib.mkIf cfg.enable {
    swapDevices = [
      {
        device = "/swapfile";
        size = cfg.size;
      }
    ];
  };
}
