{ config, lib, ... }:

let
  cfg = config.custom.services.prometheus;
in
{
  options.custom.services.prometheus = {
    server.enable = lib.mkEnableOption "Prometheus server";
    exporter.enable = lib.mkEnableOption "Prometheus node exporter";
  };

  config = {
    services.prometheus = lib.mkIf cfg.server.enable {
      enable = true;
      globalConfig.scrape_interval = "15s";
      port = 3001;
    };

    services.prometheus.exporters.node = lib.mkIf cfg.exporter.enable {
      enable = true;
      port = 9000;
    };
  };
}
