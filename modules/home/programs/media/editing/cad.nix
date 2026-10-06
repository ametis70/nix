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
    custom.programs.media.editing.cad.enable = lib.mkEnableOption "Enable CAD software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.editing.cad.enable = lib.mkDefault cfg.editing.enable;
    }
    (lib.mkIf cfg.editing.cad.enable {
    home.packages = with pkgs; [
      openscad
      freecad
    ];
    xdg.mimeApps = {
      defaultApplications =
        let
          openscad = [ "openscad.desktop" ];
        in
        lib.genAttrs [
          "application/x-openscad"
          "text/x-scad"
        ] (_: openscad);
    };

    })
  ];
}
