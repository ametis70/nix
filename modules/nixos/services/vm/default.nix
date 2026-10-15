{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.services.vm.guest;
in
{
  options.custom.services.vm.guest = {
    enable = lib.mkEnableOption "Enable guest utilities for VMs";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      spice-vdagent
      spice-autorandr
    ];

    services.spice-vdagentd.enable = true;
    services.spice-autorandr.enable = true;
  };
}
