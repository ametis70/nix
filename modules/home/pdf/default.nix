{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.custom.pdf;
in
{
  options.custom.pdf.enable = lib.mkEnableOption "PDF tooling (pdftk, mupdf, ocrmypdf, imagemagick)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      pdftk
      mupdf
      ocrmypdf
      imagemagick
    ];
  };
}
