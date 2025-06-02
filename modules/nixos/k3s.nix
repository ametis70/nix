{ config, lib, ... }:
let
  cfg = config.custom.k3s;
  localDnsInitName = "intel.lan";
  addr = "https://${localDnsInitName}:6443";
in
{
  options.custom.k3s = {
    enable = lib.mkEnableOption "Run k3s in this node";

    init = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Init cluster";
    };

    role = lib.mkOption {
      type = lib.types.str;
      default = "server";
      description = "Role for this node";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Data directory for this node";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.k3s.file = ../../secrets/k3s.age;

    services.k3s = {
      enable = true;
      role = cfg.role;
      tokenFile = config.age.secrets.k3s.path;
      extraFlags = toString (
        lib.optionals cfg.init [
          "--tls-san ${localDnsInitName}"
        ]
        ++ lib.optionals (cfg.dataDir != "") [
          "--data-dir ${cfg.dataDir}"
        ]
      );
      clusterInit = cfg.init;
      serverAddr = if cfg.init == true then "" else addr;
    };
  };
}
