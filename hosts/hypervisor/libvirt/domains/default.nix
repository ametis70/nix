{ ... }:

{
  imports = [
    ./truenas-scale.nix
    ./archlinux.nix
    ./nixos-desktop.nix
    ./nixos-server-1.nix
    ./nixos-server-2.nix
    ./nixos-server-builder.nix
  ];
}
