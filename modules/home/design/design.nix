{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gimp
    inkscape
    blender
    openscad
    audacity
    krita
  ];
}
