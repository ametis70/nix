{
  config,
  lib,
  host,
  ...
}:

let
  cfg = config.custom.services.seatd;
in
{
  options.custom.services.seatd.enable = lib.mkEnableOption "seatd service and required user groups";

  config = lib.mkIf cfg.enable {
    services.seatd = {
      enable = true;
      group = "seat";
    };

    users.users.${host.username}.extraGroups = [ "seat" ];
  };
}
