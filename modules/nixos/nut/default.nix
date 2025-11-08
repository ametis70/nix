{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.custom.nut;
  nutPasswordPath = config.age.secrets.nut.path;
  lowBatteryMinutes = 10;

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

    isVm = lib.mkEnableOption "Treat this node as a VM (use 'systemctl shutdown' instead of 'halt')";

    delay = lib.mkOption {
      type = lib.types.int;
      default = 240;
      description = "Seconds to wait before halting the node";
    };

    powerCutDelay = lib.mkOption {
      type = lib.types.int;
      default = 120;
      description = "Seconds to wait between halting the server and requesting the UPS to cut power";
    };
  };

  config = lib.mkIf cfg.enable (
    let
      systemctlCmd = "${pkgs.systemd}/bin/systemctl";
      systemctlAction = if cfg.isVm then "shutdown" else "halt";

      upscmd = lib.getExe' pkgs.nut "upscmd";

      serverShutdownCmd = pkgs.writeShellScript "nut-server-shutdown" ''
        set -euo pipefail

        IFS= read -r password < ${nutPasswordPath}
        ${upscmd} -u server -p "$password" eaton load.off.delay ${toString cfg.powerCutDelay}

        exec ${systemctlCmd} ${systemctlAction} --no-block
      '';

      clientShutdownCmd = pkgs.writeShellScript "nut-client-shutdown" ''
        set -euo pipefail

        exec ${systemctlCmd} ${systemctlAction} --no-block
      '';

      shutdownCmd = if cfg.role == "server" then serverShutdownCmd else clientShutdownCmd;
    in

    {
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
            SHUTDOWNCMD = "${shutdownCmd}";
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
    }
  );
}
