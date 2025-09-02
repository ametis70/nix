{ ... }:

{
  imports = [
    ../../modules/home/nixos.nix
    ../../modules/home/dev.nix
    ../../modules/home/kitty/kitty.nix
  ];

  home.stateVersion = "25.05";
}
