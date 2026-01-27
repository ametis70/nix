{
  pkgs,
  specialArgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../../modules/nixos/common.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/user.nix
  ];

  networking = {
    hostName = specialArgs.host.hostname;
    useDHCP = false; # Disable global DHCP, configure per interface
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
      MACAddress = "62:d9:31:bd:67:20";
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
    services.nfs.enable = true;

    nut = {
      enable = true;
      delay = 1;
      isVm = true;
      role = "client";
    };
  };

  system.stateVersion = "25.05";
}
