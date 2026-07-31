{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.crealityPrint;
  CrealityPrint = import ./package.nix { inherit pkgs; };
in
{
  options.custom.crealityPrint.enable = lib.mkEnableOption "Creality Print";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      CrealityPrint
    ];
  };
}
