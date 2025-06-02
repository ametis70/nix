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
  ];

  networking = {
    hostName = specialArgs.host.hostname;
    useDHCP = true;
    firewall.enable = false;
  };

  systemd.mounts = [
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

  boot.supportedFilesystems = [ "nfs" ];

  custom.k3s.enable = true;

  system.stateVersion = "25.05";
}
