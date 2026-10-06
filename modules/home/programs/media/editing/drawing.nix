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
    custom.programs.media.editing.drawing.enable = lib.mkEnableOption "Enable drawing software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.editing.drawing.enable = lib.mkDefault cfg.editing.enable;
    }
    (lib.mkIf cfg.editing.drawing.enable {
    home.packages = with pkgs; [
      mypaint
      krita
    ];

    xdg.mimeApps = {
      defaultApplications =
        let
          krita = [ "org.kde.krita.desktop" ];
        in
        lib.genAttrs [
          "application/x-krita"
          "application/x-krita-document"
          "image/openraster"
        ] (_: krita);
    };
    })
  ];
}
