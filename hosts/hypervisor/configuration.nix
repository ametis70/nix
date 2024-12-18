{
  config,
  lib,
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
    networkmanager.enable = false;
    useDHCP = false;
    enableIPv6 = true;
    bridges = {
      "br0" = {
        interfaces = [ "enp39s0" ];
      };
    };
    interfaces = {
      "br0" = {
        ipv4.addresses = [
          {
            address = "192.168.10.90";
            prefixLength = 24;
          }
        ];
      };
    };
    defaultGateway = "192.168.10.1";
    nameservers = [
      "192.168.10.1"
      "1.1.1.1"
    ];
  };

  environment.systemPackages = with pkgs; [
    dmidecode
    likwid
    iperf
    tcpdump
    nmap
  ];

  services.cockpit = {
    enable = true;

    package = pkgs.cockpit.overrideAttrs (old: {
      postBuild = ''
        ${old.postBuild}

        rm -rf \
          dist/apps \
          dist/kdump \
          dist/networkmanager \
          dist/packagekit \
          dist/playground \
          dist/selinux \
          dist/sosreport \
          dist/storaged
      '';
    });
  };

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
        static_configs = [ { targets = [ "192.168.10.92:9182" ]; } ];
      }
      {
        job_name = "nvidia_gpu";
        static_configs = [ { targets = [ "192.168.10.92:9835" ]; } ];
      }
    ];
  };
}
