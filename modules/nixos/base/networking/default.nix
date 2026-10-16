{
  lib,
  config,
  host,
  ...
}:

let
  cfg = config.custom.networking;
in
{
  options = {
    custom.networking.networkmanager.enable = lib.mkOption {
      description = "Enable NetworkManager";
      default = true;
      type = lib.types.bool;
    };

    custom.networking.networkd.enable = lib.mkOption {
      description = "Enable systemd-networkd";
      default = false;
      type = lib.types.bool;
    };
  };

  config = lib.mkMerge [
    {
      networking = {
        hostName = host.hostname;
        useDHCP = lib.mkDefault true;
        firewall.enable = false;
      };
    }
    (lib.mkIf cfg.networkmanager.enable {
      networking = {
        networkmanager.enable = true;
        useDHCP = false;
      };
    })
    (lib.mkIf cfg.networkd.enable {
      networking = {
        networkmanager.enable = false;
        useNetworkd = true;
        useDHCP = false;
      };
    })
  ];
}
