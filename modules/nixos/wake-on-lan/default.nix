{ lib, config, ... }:

let
  cfg = config.custom.wakeOnLan;
in
{
  options.custom.wakeOnLan = {
    enable = lib.mkEnableOption "Wake-on-LAN for a network interface";
    interface = lib.mkOption {
      type = lib.types.str;
      description = "Interface to enable Wake-on-LAN on.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.interfaces.${cfg.interface}.wakeOnLan.enable = true;
  };
}
