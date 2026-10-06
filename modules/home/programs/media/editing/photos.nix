{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.custom.programs.media;
in
{
  options = {
    custom.programs.media.editing.photos.enable = lib.mkEnableOption "Enable photos editing software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.editing.photos.enable = lib.mkDefault cfg.editing.enable;
    }
    (lib.mkIf cfg.editing.photos.enable {
      home.packages = with pkgs; [
        hdrmerge
        darktable
        exiftool
      ];
    })
  ];
}
