{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.services.nfs;
in
{
  options = {
    custom.services.nfs = {
      enable = lib.mkEnableOption "Enable NFS and mount common shares";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.nfs-utils
    ];

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
      {
        name = "srv-nfs-photos.mount";
        wantedBy = [ "multi-user.target" ];
        what = "truenas.lan:/mnt/main/photos";
        where = "/srv/nfs/photos";
        type = "nfs";
        options = "nfsvers=4.2";
      }
      {
        name = "srv-nfs-games.mount";
        wantedBy = [ "multi-user.target" ];
        what = "truenas.lan:/mnt/main/games";
        where = "/srv/nfs/games";
        type = "nfs";
        options = "nfsvers=4.2";
      }
      {
        name = "srv-nfs-music.mount";
        wantedBy = [ "multi-user.target" ];
        what = "truenas.lan:/mnt/main/media/music";
        where = "/srv/nfs/music";
        type = "nfs";
        options = "nfsvers=4.2";
      }
    ];

    boot.supportedFilesystems = [ "nfs" ];
  };
}
