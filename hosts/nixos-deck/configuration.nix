{ lib, specialArgs, ... }:

{
  imports = [
    ../../modules/nixos/common.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/user.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/pipewire.nix
    ../../modules/nixos/hyprland.nix
    ../../modules/nixos/keyring.nix

    ../../modules/nixos/guest-user.nix

    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "discord" ];

  networking = {
    hostName = specialArgs.host.hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };
}
