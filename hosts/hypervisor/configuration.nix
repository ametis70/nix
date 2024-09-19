{ config, lib, pkgs, specialArgs, ... }:

{
  imports = [ ./hardware-configuration.nix ./debug.nix ./libvirt/libvirt.nix ];

  system.stateVersion = "24.05";
  system.copySystemConfiguration = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  users.users.ametis70 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAvjO5PcjSiiAnAV3oRFDNgzGiV7HdlkocRw6uJCs0/w"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDA07n+GRqAPcZa8EGh4LvF57RjUOHXdp+942VJrjWqk"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTMwKGTiKKaOXosdBnAlCl7MC6CT8JAI1nZsB/1VLKV"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWznt23SwzkAuVook9PU9fvYvbvmFpoxhPTzHRnTvNI"
    ];
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  networking = {
    hostName = specialArgs.host.hostname;
    firewall.enable = false;
    networkmanager.enable = false;
    useDHCP = false;
    enableIPv6 = false;
    bridges = { "br0" = { interfaces = [ "enp39s0" ]; }; };
    interfaces = {
      "br0" = {
        ipv4.addresses = [{
          address = "192.168.10.90";
          prefixLength = 24;
        }];
      };
    };
    defaultGateway = "192.168.10.1";
    nameservers = [ "192.168.10.1" ];
  };

  time.timeZone = "America/Argentina/Buenos_Aires";

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  environment.systemPackages = with pkgs; [
    zsh
    curl
    fd
    fzf
    git
    lazygit
    dmidecode
    pciutils
    usbutils
    likwid
    tree
  ];

  programs.tmux.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };

  services.cockpit.enable = true;

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
          {
            targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
      {
        job_name = "windows";
        static_configs = [
          {
            targets = [ "192.168.10.92:9182" ];
          }
        ];
      }
      {
        job_name = "nvidia_gpu";
        static_configs = [
          {
            targets = [ "192.168.10.92:9835" ];
          }
        ];
      }
    ];
  };
}
