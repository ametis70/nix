{
  pkgs,
  inputs,
  specialArgs,
  ...
}:

let
  nutPasswordPath = "/etc/nut/password";
  iscsiIqn = "iqn.2025-03.local.nas";
  iscsiPortal = "truenas.lan";
in
{
  imports = [
    ../../modules/nixos/common.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/user.nix
    ../../modules/nixos/docker.nix

    "${inputs.argononed}/OS/nixos"
  ];

  networking = {
    hostName = specialArgs.host.hostname;
    useDHCP = true;
    firewall.enable = false;
  };

  users.users.root.initialPassword = "root";

  raspberry-pi-nix.board = "bcm2711";
  hardware.raspberry-pi.i2c.enable = true;
  hardware.deviceTree.filter = "bcm2711-rpi-*.dtb";

  boot.loader = {
    systemd-boot.enable = false;
  };

  virtualisation.docker.daemon.settings = {
    live-restore = false; # Required for docker swarm
  };

  environment.systemPackages = with pkgs; [
    nut
    nfs-utils
  ];

  systemd.tmpfiles.rules = [
    "d /mnt/nfs               755 0    0"
    "d /mnt/nfs/docker/config 755 1000 100"
    "d /mnt/nfs/docker/data   755 1000 100"
  ];

  fileSystems = {
    "/mnt/nfs/docker/config" = {
      device = "nas.lan:/export/docker/config";
      fsType = "nfs";
    };

    "/mnt/nfs/docker/data" = {
      device = "nas.lan:/export/docker/data";
      fsType = "nfs";
    };
  };

  power.ups = {
    enable = true;
    mode = "netserver";

    ups."eaton" = {
      driver = "usbhid-ups";
      port = "auto";
      # vendorId = "0463";
      # productId = "FFFF";
    };

    upsmon = {
      enable = true;
      monitor.eaton = {
        user = "nut";
        system = "localhost@eaton";
        type = "master";
        powerValue = 1;
        passwordFile = nutPasswordPath;
      };
    };

    users."nut" = {
      upsmon = "primary";
      passwordFile = nutPasswordPath;
    };

    upsd = {
      enable = true;
      listen = [
        {
          address = "0.0.0.0";
        }
      ];
    };
  };

  services.prometheus.exporters.nut = {
    enable = true;
    nutUser = "nut";
    passwordPath = nutPasswordPath;
  };

  services.openiscsi = {
    enable = true;
    name = "${iscsiIqn}:rpi4-juglares";
    discoverPortal = iscsiPortal;
  };

  systemd.services.iscsi-login = {
    description = "Login to iSCSI target";
    after = [
      "network.target"
      "iscsid.service"
    ];
    wants = [ "iscsid.service" ];
    serviceConfig = {
      ExecStartPre = "${pkgs.openiscsi}/bin/iscsiadm -m discovery -t sendtargets -p truenas.lan";
      ExecStart = "${pkgs.openiscsi}/bin/iscsiadm -m node -T ${iscsiIqn}:truenas:rpi4-juglares -p ${iscsiPortal} --login";
      ExecStop = "${pkgs.openiscsi}/bin/iscsiadm -m node -T ${iscsiIqn}:truenas:rpi4-juglares -p ${iscsiPortal} --logout";
      Restart = "on-failure";
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.mounts = [
    {
      name = "data-docker.mount";
      after = [ "iscsi-login.service" ];
      what = "/dev/disk/by-path/ip-192.168.88.60:3260-iscsi-${iscsiIqn}:truenas:rpi4-juglares-lun-0-part1";
      where = "/data/docker";
      type = "ext4";
      options = "_netdev,nofail";
    }
    {
      name = "data-gfs-brick1.mount";
      after = [ "iscsi-login.service" ];
      what = "/dev/disk/by-path/ip-192.168.88.60:3260-iscsi-${iscsiIqn}:truenas:rpi4-juglares-lun-1-part1";
      where = "/data/gfs/brick1";
      type = "ext4";
      options = "_netdev,nofail";

    }
    {
      name = "srv-gfs.mount";
      after = [ "glusterd.service" ];
      what = "localhost:/gv0";
      where = "/srv/gfs";
      type = "glusterfs";
      options = "defaults";
    }
  ];

  services.glusterfs.enable = true;

  systemd.services.glusterd = {
    after = [ "data-gfs-brick1.mount" ];
    wants = [ "data-gfs-brick1.mount" ];
  };

  systemd.services.docker = {
    wants = [
      "data-docker.mount"
      "srv-gfs.mount"
    ];
    after = [
      "data-docker.mount"
      "srv-gfs.mount"
    ];
  };

  virtualisation.docker.daemon.settings = {
    data-root = "/data/docker/daemon";
  };

  # Argon ONE V2 case
  # FIXME: The argonone overlay for argononed is not working and the settings are not being picked up

  disabledModules = [ "services/hardware/argonone.nix" ];

  hardware.raspberry-pi.config = {
    all = {
      dt-overlays = {
        argonone = {
          enable = true;
          params = { };
        };
      };
    };
  };

  services.argonone = {
    enable = true;
    logLevel = 4;
    settings = {
      fanTemp0 = 36;
      fanSpeed0 = 10;
      fanTemp1 = 41;
      fanSpeed1 = 50;
      fanTemp2 = 46;
      fanSpeed2 = 80;
      hysteresis = 4;
    };
  };

  system.stateVersion = "24.11";
}
