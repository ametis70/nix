{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.development.docker;
in

{
  options.custom.development.docker = {
    enable = lib.mkEnableOption "Enable Docker";
  };

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
