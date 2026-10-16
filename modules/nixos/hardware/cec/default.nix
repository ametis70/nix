{
  config,
  lib,
  host,
  pkgs,
  ...
}:

let
  cfg = config.custom.hardware.cec;
in
{
  options.custom.hardware.cec.enable = lib.mkEnableOption "CEC adapter support";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.libcec ];
    users.users.${host.username}.extraGroups = [ "dialout" ];
  };
}
