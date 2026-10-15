{ config, lib, ... }:

let
  cfg = config.custom.power;
in
{
  options.custom.power = {
    sleep.enable = lib.mkEnableOption "Enable sleep";
    power-profiles-daemon.enable = lib.mkEnableOption "Enable power-profiles-daemon";
  };

  config = {
    systemd.targets = {
      sleep.enable = cfg.sleep.enable;
      suspend.enable = cfg.sleep.enable;
      hibernate.enable = cfg.sleep.enable;
      hybrid-sleep.enable = cfg.sleep.enable;
    };

    services.power-profiles-daemon.enable = cfg.power-profiles-daemon.enable;
  };
}
