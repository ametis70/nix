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
    custom.programs.media.editing.documents.enable = lib.mkEnableOption "Enable documents editing software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.editing.documents.enable = lib.mkDefault cfg.editing.enable;
    }
    (lib.mkIf cfg.editing.documents.enable {
    programs.calibre = {
      enable = true;
    };

    programs.pandoc = {
      enable = true;
    };

    home.packages = with pkgs; [
      libreoffice-qt
    ];
    })
  ];
}
