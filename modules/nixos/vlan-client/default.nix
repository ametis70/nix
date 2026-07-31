{ lib, config, pkgs, ... }:

let
  cfg = config.custom.vlanClient;
in
{
  options.custom.vlanClient = {
    enable = lib.mkEnableOption "systemd-networkd VLAN client (native network + tagged VLAN)";

    interface = lib.mkOption {
      type = lib.types.str;
      default = "enp1s0";
      description = "Physical interface carrying the native (untagged) network.";
    };

    vlanMac = lib.mkOption {
      type = lib.types.str;
      description = "MAC address of the tagged VLAN interface.";
    };

    vlanId = lib.mkOption {
      type = lib.types.int;
      default = 20;
      description = "VLAN id (only used when createVlanNetdev = true).";
    };

    createVlanNetdev = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        When true, create the tagged VLAN interface locally via a netdev (this
        host tags the VLAN). When false, rename an already-present interface to
        vlan20 by MAC via a link (the VLAN is provided upstream, e.g. by the
        hypervisor bridge).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      useDHCP = false;
      useNetworkd = true;
    };

    systemd.network = {
      enable = true;

      netdevs = lib.mkIf cfg.createVlanNetdev {
        "30-vlan20" = {
          netdevConfig = {
            Kind = "vlan";
            Name = "vlan20";
            MACAddress = cfg.vlanMac;
          };
          vlanConfig = {
            Id = cfg.vlanId;
          };
        };
      };

      links = lib.mkIf (!cfg.createVlanNetdev) {
        "30-vlan20" = {
          matchConfig = {
            MACAddress = cfg.vlanMac;
          };
          linkConfig = {
            Name = "vlan20";
          };
        };
      };

      networks = {
        "30-${cfg.interface}" = {
          name = cfg.interface;
          DHCP = "yes";
          dhcpV4Config = {
            RouteMetric = 100;
          };
        }
        // lib.optionalAttrs cfg.createVlanNetdev {
          vlan = [ "vlan20" ];
        };
        "30-vlan20" = {
          name = "vlan20";
          DHCP = "yes";
          dhcpV4Config = {
            RouteMetric = 200;
          };
        };
      };
    };

    systemd.services.systemd-networkd-wait-online.serviceConfig.ExecStart = [
      "" # Clear the existing ExecStart
      "${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online --interface=${cfg.interface} --timeout=60"
    ];
  };
}
