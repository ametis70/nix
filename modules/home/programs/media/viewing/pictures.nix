{
  config,
  lib,
  ...
}:

let
  cfg = config.custom.programs.media;
in
{
  options = {
    custom.programs.media.viewing.pictures.enable = lib.mkEnableOption "Enable pictures viewing software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.viewing.pictures.enable = lib.mkDefault cfg.viewing.enable;
    }
    (lib.mkIf cfg.viewing.pictures.enable {
    programs.imv = {
      enable = true;
    };

    xdg.mimeApps = {
      defaultApplications =
        let
          imv = [ "imv-dir.desktop" ];
        in
        lib.genAttrs [
          # imv
          "image/jpeg"
          "image/png"
          "image/gif"
          "image/webp"
          "image/bmp"
          "image/tiff"
          "image/avif"
          "image/heif"
          "image/heic"
          "image/jxl"
          "image/x-tga"
          "image/x-icon"
          "image/x-dds"
          "image/x-exr"
          "image/x-psd"
        ] (_: imv);
    };
    })
  ];
}
