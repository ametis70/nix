{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pdftk
    mupdf
    ocrmypdf
    imagemagick
  ];
}
