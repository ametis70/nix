{ ... }:

{
  imports = [
    ../../modules/home/dev.nix
  ];

  custom.fonts.enable = true;
  custom.kitty.enable = true;
  custom.hvm.enable = true;

  home.stateVersion = "24.11";
}
