{ lib, specialArgs, ... }:

{
  imports = [
    ../../modules/nixos/common.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/user.nix
    ../../modules/nixos/guest.nix
    ../../modules/nixos/printing.nix
    ../../modules/nixos/scanning.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/pipewire.nix
    ../../modules/nixos/hyprland.nix
    ../../modules/nixos/keyring.nix

    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "imagescan-plugin-networkscan"
    ];

  networking = {
    hostName = specialArgs.host.hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };
}
