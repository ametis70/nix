{ config, lib, ... }:

let
  cfg = config.custom.timezone;
in

{
  options = {
    custom.timezone.dynamic = lib.mkOption {
      description = "Enable dynamic timezone";
      default = true;
      type = lib.types.bool;
    };
  };

  config = lib.mkMerge [
    {
      time.timeZone = lib.mkDefault "America/Argentina/Buenos_Aires";
    }
    (lib.mkIf cfg.dynamic {
      time.timeZone = null;
      location.provider = "geoclue2";
      services.geoclue2 = {
        enable = true;
      };
      services.automatic-timezoned.enable = true;
    })
  ];
}
