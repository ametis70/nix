{
  pkgs,
  specialArgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

  ];

  networking = {
    hostName = specialArgs.host.hostname;
    useDHCP = false;
    useNetworkd = true;
    firewall.enable = false;
  };

  systemd.network = {
    enable = true;
    networks = {
      "30-enp1s0" = {
        name = "enp1s0";
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 100;
        };
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

  systemd.network.links."30-vlan20" = {
    matchConfig = {
      MACAddress = "98:b1:c7:e9:32:20";
    };
    linkConfig = {
      Name = "vlan20";
    };
  };

  systemd.services.systemd-networkd-wait-online = {
    serviceConfig = {
      ExecStart = [
        ""
        "${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online --interface=enp1s0 --timeout=60"
      ];
    };
  };

  custom = {
    k3s.enable = true;
    nfs.enable = true;

    nut = {
      enable = true;
      delay = 1;
      isVm = true;
      role = "client";
    };
  };

  system.stateVersion = "25.05";
}
