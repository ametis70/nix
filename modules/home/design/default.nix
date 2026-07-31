{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.custom.design;
in
{
  options.custom.design.enable = lib.mkEnableOption "design/creative tooling (godot, gimp, blender, ...)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      inputs.nixpkgs.legacyPackages.x86_64-linux.godotPackages_4_6.godot
      gimp
      inkscape
      blender
      openscad
      audacity
      krita
    ];
  };
}
