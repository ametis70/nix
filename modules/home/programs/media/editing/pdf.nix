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
    custom.programs.media.editing.pdf.enable = lib.mkEnableOption "Enable pdf editing software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.editing.pdf.enable = lib.mkDefault cfg.editing.enable;
    }
    (lib.mkIf cfg.editing.pdf.enable {
    home.packages = with pkgs; [
      pdftk
      mupdf
      ocrmypdf
    ];
    })
  ];
}
