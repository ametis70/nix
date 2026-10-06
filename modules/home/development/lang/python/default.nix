{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.custom.development.lang.python;
in
{
  options.custom.development.lang.python = {
    enable = lib.mkEnableOption "Enable Python development tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      python3
    ];
  };
}
