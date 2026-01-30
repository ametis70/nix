{ pkgs, ... }:

{
  home.packages = with pkgs; [
    godot
    gimp
    inkscape
    blender
    openscad
    audacity
    krita
  ];
}
