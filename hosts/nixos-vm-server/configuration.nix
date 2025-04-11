{
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

  system.stateVersion = "24.11";
}
