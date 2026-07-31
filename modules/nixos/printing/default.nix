{ lib, config, ... }:

let
  cfg = config.custom.printing;
in
{
  options.custom.printing.enable = lib.mkEnableOption "CUPS printing + Avahi mDNS discovery";

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };
}
