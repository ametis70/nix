{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.custom.development.lang.go;
in
{
  options.custom.development.lang.go = {
    enable = lib.mkEnableOption "Enable Go development tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      go
    ];
  };
}
