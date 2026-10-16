{ config, lib, ... }:

let
  cfg = config.custom.services.prometheus;
in
{
  options.custom.services.prometheus = {
    server.enable = lib.mkEnableOption "Prometheus server";
    exporter.enable = lib.mkEnableOption "Prometheus node exporter";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.server.enable {
      services.prometheus = {
        enable = true;
        globalConfig.scrape_interval = "15s";
        port = 3001;
      };
    })
    (lib.mkIf cfg.exporter.enable {
      services.prometheus.exporters.node = {
        enable = true;
        port = 9000;
      };
    })
  ];
}
