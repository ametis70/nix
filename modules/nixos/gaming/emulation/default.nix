{
  lib,
  config,
  ...
}:

let
  cfg = config.custom.gaming.emulation;
in
{
  options.custom.gaming.emulation = {
    enable = lib.mkEnableOption "emulation NixOS support";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePackages = [
      "libretro-fbneo"
      "libretro-genesis-plus-gx"
      "libretro-picodrive"
      "libretro-snes9x"
    ];
  };
}
