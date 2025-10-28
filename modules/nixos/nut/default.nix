{ lib, config, ... }:

let
  cfg = config.custom.nut;
  nutPasswordPath = config.age.secrets.nut.path;
  lowBatteryMinutes = 9;

  modeMap = {
    server = "netserver";
    client = "netclient";
  };
  monitorMap = {
    server = "master";
    client = "slave";
  };
  clientMap = {
    server = "localhost";
    client = "intel.lan";
  };
in

{
  options.custom.nut = {
    enable = lib.mkEnableOption "Enable NUT on this node";

    role = lib.mkOption {
      type = lib.types.enum [
        "server"
        "client"
      ];
      default = "client";
      description = "Role for this node";
    };

    delay = lib.mkOption {
      type = lib.types.int;
      default = 5 * 60;
      description = "Seconds to wait before shuting down node";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.nut.file = ../../../secrets/nut.age;

    power.ups = {
      enable = true;
      mode = modeMap.${cfg.role};

      upsmon = {
        enable = true;
        monitor.eaton = {
          user = cfg.role;
          system = "eaton@${clientMap.${cfg.role}}";
          type = monitorMap.${cfg.role};
          powerValue = 1;
          passwordFile = nutPasswordPath;
        };
        settings = {
          SHUTDOWNCMD = "/run/current-system/sw/sbin/shutdown -h +0";
          FINALDELAY = toString cfg.delay;
        };
      };

      ups."eaton" = lib.mkIf (cfg.role == "server") {
        driver = "usbhid-ups";
        port = "auto";
        directives = [
          "override.battery.runtime.low = ${toString (lowBatteryMinutes * 60)}"
        ];
        # vendorId = "0463";
        # productId = "FFFF";
      };

      users = lib.mkIf (cfg.role == "server") {
        "server" = {
          upsmon = "primary";
          passwordFile = nutPasswordPath;
          actions = [
            "SET"
            "FSD"
            "INSTCMD"
          ];
          instcmds = [
            "load.off"
            "load.off.delay"
            "shutdown.stop"
            "beeper.enable"
            "beeper.disable"
          ];
        };
        "client" = {
          upsmon = "secondary";
          passwordFile = nutPasswordPath;
        };
      };

      upsd = lib.mkIf (cfg.role == "server") {
        enable = true;
        listen = [
          {
            address = "0.0.0.0";
          }
        ];
      };
    };

    services.prometheus.exporters.nut = lib.mkIf (cfg.role == "server") {
      enable = true;
      nutUser = "prometheus";
      passwordPath = nutPasswordPath;
      user = "root";
      group = "root";
    };
  };
}
