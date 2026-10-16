{ config, lib, ... }:

let
  cfg = config.custom.services.grafana;
in
{
  options.custom.services.grafana.enable = lib.mkEnableOption "Grafana service";

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings.server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
      };
      provision.datasources.settings.datasources = lib.mkIf config.custom.services.prometheus.server.enable [
        {
          name = "prometheus";
          type = "prometheus";
          url = "http://localhost:${toString config.services.prometheus.port}";
        }
      ];
    };
  };
}
