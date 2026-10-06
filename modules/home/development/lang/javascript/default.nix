{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.custom.development.lang.javascript;
in
{
  options.custom.development.lang.javascript = {
    enable = lib.mkEnableOption "Enable JavaScript development tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs
    ];
  };
}
