{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    inputs.nixpkgs.legacyPackages.x86_64-linux.godotPackages_4_6.godot
    gimp
    inkscape
    blender
    openscad
    audacity
    krita
  ];
}
