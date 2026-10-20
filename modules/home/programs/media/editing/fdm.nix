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
    custom.programs.media.editing.fdm.enable = lib.mkEnableOption "Enable FDM 3D printing software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.editing.fdm.enable = lib.mkDefault cfg.editing.enable;
    }
    (lib.mkIf cfg.editing.fdm.enable {
      home.packages = with pkgs; [
        orca-slicer
      ];
    })
  ];
}
