{ ... }:

{
  imports = [
    ../../modules/home/nixos.nix
    ../../modules/home/dev.nix
  ];

  home.stateVersion = "24.11";
}
