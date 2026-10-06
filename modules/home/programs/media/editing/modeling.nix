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
    custom.programs.media.editing.modeling.enable = lib.mkEnableOption "Enable 3D modeling software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.editing.modeling.enable = lib.mkDefault cfg.editing.enable;
    }
    (lib.mkIf cfg.editing.modeling.enable {
    home.packages = with pkgs; [
      blender
    ];

    xdg.mimeApps = {
      defaultApplications =
        let
          blender = [ "blender.desktop" ];
        in
        lib.genAttrs [
          "application/x-blender"
          "application/x-blender-project"
        ] (_: blender);
    };

    })
  ];
}
