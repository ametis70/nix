{ lib, config, pkgs, ... }:

let
  cfg = config.custom.guest;
in
{
  options.custom.guest.enable = lib.mkEnableOption "SPICE guest tooling (vdagent, autorandr)";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      spice-vdagent
      spice-autorandr
    ];

    services.spice-vdagentd.enable = true;
    services.spice-autorandr.enable = true;
  };
}
