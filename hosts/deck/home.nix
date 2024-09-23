{ pkgs, lib, ... }:

let
  nixgl = import ../../utils/nixgl.nix { inherit pkgs; inherit lib; };
in {
  imports = [ ../../modules/home/linux.nix ];

  home.packages = with pkgs; [
    (nixgl.wrapMesa kitty)
  ];
}
