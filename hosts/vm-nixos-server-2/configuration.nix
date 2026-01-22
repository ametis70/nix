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
      # VLAN 30 interface (existing - for K3s cluster)
      "30-enp1s0" = {
        name = "enp1s0";
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 100; # Lower metric = higher priority
        };
      };
      # VLAN 20 interface (new)
      "30-enp2s0" = {
        name = "enp2s0";
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 200; # Higher metric = lower priority
        };
      };
    };
  };

  # Configure systemd-networkd-wait-online to only wait for the primary interface
  systemd.services.systemd-networkd-wait-online = {
    serviceConfig = {
      ExecStart = [
        "" # Clear the existing ExecStart
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
