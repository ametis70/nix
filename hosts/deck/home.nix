{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/home/linux.nix
    ../../modules/home/dev.nix
    ../../modules/home/kitty/kitty.nix
    ../../modules/home/hypervisor-virt-manager/hvm.nix

  ];

  home.stateVersion = "24.11";
}
