{ config, lib, ... }:

let
  cfg = config.custom.timezone;
in

{
  options = {
    custom.timezone.dynamic = lib.mkEnableOption "Enable dynamic timezone";
  };

  config = lib.mkMerge [
    {
      time.timeZone = lib.mkDefault "America/Argentina/Buenos_Aires";
    }
    (lib.mkIf cfg.dynamic {
      time.timeZone = lib.mkForce null;
      location.provider = "geoclue2";
      services.geoclue2 = {
        enable = true;
      };
      services.automatic-timezoned.enable = true;
    })
  ];
}
