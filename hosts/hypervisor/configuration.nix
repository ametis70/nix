{
  config,
  pkgs,
  specialArgs,
  ...
}:

{
  imports = [
    ../../modules/nixos/common.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/user.nix

    ./hardware-configuration.nix
    ./debug.nix
    ./libvirt/libvirt.nix
  ];

  users.users.ametis70.extraGroups = [ "libvirtd" ];

  networking = {
    hostName = specialArgs.host.hostname;
    firewall.enable = false;
    useNetworkd = true;
  };

  systemd.network = {
    enable = true;
    netdevs = {
      "30-br0" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br0";
          MACAddress = "none";
        };
      };
    };
    networks = {
      "30-enp39s0" = {
        name = "enp39s0";
        bridge = [ "br0" ];
      };
      "30-br0" = {
        name = "br0";
        DHCP = "yes";
      };
    };
    links = {
      "30-br0" = {
        matchConfig = {
          OriginalName = "br0";
        };
        linkConfig = {
          MACAddressPolicy = "none";
        };
      };
    };
  };

  networking.interfaces.enp39s0.wakeOnLan.enable = true;

  environment.systemPackages = with pkgs; [
    dmidecode
    likwid
    iperf
    tcpdump
    nmap
  ];

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
      };
    };
    provision.datasources.settings.datasources = [
      {
        name = "prometheus";
        type = "prometheus";
        url = "http://localhost:${toString config.services.prometheus.port}";
      }
    ];
  };

  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "15s";
    port = 3001;

    exporters.node = {
      enable = true;
      port = 9000;
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          { targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ]; }
        ];
      }
      {
        job_name = "windows";
        static_configs = [ { targets = [ "windows.lan:9182" ]; } ];
      }
      {
        job_name = "nvidia_gpu";
        static_configs = [ { targets = [ "windows.lan:9835" ]; } ];
      }
      {
        job_name = "nut";
        static_configs = [
          {
            targets = [ "intel.lan:9199" ];
            labels = {
              "__metrics_path__" = "/ups_metrics";
            };
          }
        ];
      }
    ];
  };

  custom = {
    nut = {
      enable = true;
      delay = 120;
      role = "client";
    };
  };

  system.stateVersion = "24.11";
}
