{
  lib,
  config,
  ...
}:

let
  cfg = config.custom.emulation;
in
{
  options.custom.emulation = {
    enable = lib.mkEnableOption "emulation NixOS support";

    allowedUnfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "libretro-fbneo"
        "libretro-genesis-plus-gx"
        "libretro-picodrive"
        "libretro-snes9x"
      ];
      description = "Unfree package names required by the emulation setup.";
    };
  };
}
