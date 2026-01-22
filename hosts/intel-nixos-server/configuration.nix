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

  systemd.network = {
    enable = true;
    netdevs = {
      # Only VLAN 20 interface needed (VLAN 30 is native)
      "30-vlan20" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan20";
          MACAddress = "00:e0:4c:74:51:20"; # Custom MAC for VLAN 20
        };
        vlanConfig = {
          Id = 20;
        };
      };
    };
    networks = {
      # Physical interface configuration (handles native VLAN 30)
      "30-enp1s0" = {
        name = "enp1s0";
        vlan = [ "vlan20" ]; # Only create tagged VLAN 20
        DHCP = "yes"; # DHCP for native VLAN 30
        dhcpV4Config = {
          RouteMetric = 100; # Lower metric = higher priority (VLAN 30 primary)
        };
      };
      # VLAN 20 interface (tagged for IoT)
      "30-vlan20" = {
        name = "vlan20";
        DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 200; # Higher metric = lower priority (IoT secondary)
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
