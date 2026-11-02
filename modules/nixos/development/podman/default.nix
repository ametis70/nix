{
  pkgs,
  lib,
  config,
  host,
  ...
}:

let
  cfg = config.custom.development.podman;
in

{
  options.custom.development.podman = {
    enable = lib.mkEnableOption "Enable Podman";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true; # `docker` becomes a symlink to `podman`
      defaultNetwork.settings.dns_enabled = true; # containers talk to each other (podman-compose)
    };

    # Rootless Podman needs subuid/subgid ranges for your user
    users.users.${host.username} = {
      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
      ];
    };

    # Compose provider for `podman compose`
    environment.systemPackages = [ pkgs.docker-compose ];
  };
}
