{ pkgs, specialArgs, lib, ... }:

let
  nixgl = import ../../utils/nixgl.nix { inherit pkgs; inherit lib; };
in {
  imports = [ ../linux.nix ];

  home.packages = with pkgs; [
    (nixgl.wrapMesa kitty)
  ];

}
