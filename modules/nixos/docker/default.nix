{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.custom.docker;
in
{
  options.custom.docker.enable = lib.mkEnableOption "Docker (with compose + buildx)";

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
    };

    environment.systemPackages = with pkgs; [
      docker-compose
      docker-buildx
    ];
  };
}
