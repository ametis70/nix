{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.programs.creality-print;
  CrealityPrint = import ./package.nix { inherit pkgs; };
in
{
  options = {
    custom.programs.creality-print.enable = lib.mkEnableOption "Install Creality Print";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      CrealityPrint
    ];
  };
}
