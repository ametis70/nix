{
  pkgs,
  specialArgs,
  ...
}:

let
  nutPasswordPath = "/etc/nut/password";
in
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../../modules/nixos/common.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/user.nix
    ../../modules/nixos/docker.nix
  ];

  networking = {
    hostName = specialArgs.host.hostname;
    useDHCP = true;
    firewall.enable = false;
  };

  virtualisation.docker.daemon.settings = {
    live-restore = false; # Required for docker swarm
  };

  services.glusterfs.enable = true;

  systemd.mounts = [
    {
      name = "srv-gfs.mount";
      after = [ "glusterd.service" ];
      what = "localhost:/gv0";
      where = "/srv/gfs";
      type = "glusterfs";
      options = "defaults";
    }
    {
      name = "srv-nfs-movies.mount";
      wantedBy = [ "multi-user.target" ];
      what = "truenas.lan:/mnt/main/media/movies";
      where = "/srv/nfs/movies";
      type = "nfs";
      options = "nfsvers=4.2";
    }
    {
      name = "srv-nfs-tv.mount";
      wantedBy = [ "multi-user.target" ];
      what = "truenas.lan:/mnt/main/media/tv";
      where = "/srv/nfs/tv";
      type = "nfs";
      options = "nfsvers=4.2";
    }
    {
      name = "srv-nfs-downloads.mount";
      wantedBy = [ "multi-user.target" ];
      what = "truenas.lan:/mnt/main/downloads";
      where = "/srv/nfs/downloads";
      type = "nfs";
      options = "nfsvers=4.2";
    }
  ];

  systemd.services.docker = {
    wants = [
      "srv-gfs.mount"
      "srv-nfs-movies.mount"
      "srv-nfs-tv.mount"
      "srv-nfs-downloads.mount"
    ];
    after = [
      "srv-gfs.mount"
      "srv-nfs-movies.mount"
      "srv-nfs-tv.mount"
      "srv-nfs-downloads.mount"
    ];
  };

  boot.supportedFilesystems = [ "nfs" ];

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      vaapiVdpau
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };

  services.jellyfin.enable = true;

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];

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

  custom.k3s.enable = true;

  system.stateVersion = "24.11";
}
