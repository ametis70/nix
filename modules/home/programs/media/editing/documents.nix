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
    custom.programs.media.editing.documents.enable =
      lib.mkEnableOption "Enable documents editing software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.editing.documents.enable = lib.mkDefault cfg.editing.enable;
    }
    (lib.mkIf cfg.editing.documents.enable {
      home.packages = with pkgs; [
        calibre
        pandoc
        libreoffice-qt
      ];
    })
  ];
}
