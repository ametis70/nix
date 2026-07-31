{ ... }:

{
  imports = [
    ../../modules/home/dev.nix
  ];

  custom.kitty.enable = true;

  home.stateVersion = "25.05";
}
