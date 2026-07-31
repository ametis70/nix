{ ... }:

{
  imports = [
    ../../modules/home/dev.nix
    ../../modules/home/kitty/kitty.nix
    ../../modules/home/hypervisor-virt-manager/hvm.nix
  ];

  custom.fonts.enable = true;

  home.stateVersion = "24.11";
}
