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
    useNetworkd = true; # Enable systemd-networkd for advanced networking
    firewall.enable = false;
  };

  boot.kernel.sysctl = {
    # Enable IP forwarding (required for any routing/relay)
    "net.ipv4.ip_forward" = 1;

    # Keep strict mode globally for security
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    # Disable only on VLAN interfaces used for multicast relay
    "net.ipv4.conf.vlan10.rp_filter" = 0;
    "net.ipv4.conf.vlan20.rp_filter" = 0;
    "net.ipv4.conf.vlan100.rp_filter" = 0;
  };

  systemd.network = {
    enable = true;
    netdevs = {
      "30-vlan10" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan10";
          MACAddress = "00:e0:4c:74:51:10";
        };
        vlanConfig = {
          Id = 10;
        };
      };
      "30-vlan20" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan20";
          MACAddress = "00:e0:4c:74:51:20";
        };
        vlanConfig = {
          Id = 20;
        };
      };
      "30-vlan100" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan100";
          MACAddress = "00:e0:4c:74:51:64";
        };
        vlanConfig = {
          Id = 100;
        };
      };
    };
    networks = {
      "30-enp1s0" = {
        name = "enp1s0";
        vlan = [
          "vlan10"
          "vlan20"
          "vlan100"
        ];
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 100;
        };
      };
      "30-vlan10" = {
        name = "vlan10";
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 150;
        };
      };
      "30-vlan20" = {
        name = "vlan20";
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 200;
        };
      };
      "30-vlan100" = {
        name = "vlan100";
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 250;
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

  networking.interfaces.enp1s0.wakeOnLan.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];

  custom = {
    k3s = {
      enable = true;
      init = true;
      interface = "enp1s0"; # Use physical interface for VLAN 30 (native)
    };

    nut = {
      enable = true;
      role = "server";
    };

    services.nfs.enable = true;
  };

  system.stateVersion = "24.11";
}
