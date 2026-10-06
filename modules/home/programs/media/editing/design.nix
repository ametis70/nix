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
    custom.programs.media.editing.design.enable = lib.mkEnableOption "Enable graphic design software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.editing.design.enable = lib.mkDefault cfg.editing.enable;
    }
    (lib.mkIf cfg.editing.design.enable {
    home.packages = with pkgs; [
      imagemagick
      gimp
      inkscape
    ];

    xdg.mimeApps = {
      defaultApplications =
        let
          gimp = [ "gimp.desktop" ];
          inkscape = [ "org.inkscape.Inkscape.desktop" ];
        in
        lib.genAttrs [
          "image/x-xcf"
        ] (_: gimp)

        // lib.genAttrs [
          "image/svg+xml"
          "application/vnd.inkscape.svg+xml"
        ] (_: inkscape);
    };
    })
  ];
}
