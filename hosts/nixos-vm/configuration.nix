{
  pkgs,
  lib,
  inputs,
  specialArgs,
  ...
}:

let
  hyprland-nixpkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
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
    ../../modules/nixos/greetd.nix
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

  systemd.services.nix-daemon.serviceConfig = {
    MemoryAccounting = true;
    MemoryMax = "85%";
    OOMScoreAdjust = 500;
  };

  systemd.tmpfiles.rules = [
    "d /export               755 0    0"
    "d /export/docker/config 755 1000 100"
    "d /export/docker/data   755 1000 100"
  ];

  services.nfs = {
    server = {
      enable = true;
      exports = ''
        /export/docker/config  192.168.88.0/24(rw,sync,nohide,no_subtree_check,insecure,no_root_squash)
        /export/docker/data    192.168.88.0/24(rw,sync,nohide,no_subtree_check,insecure,no_root_squash)
      '';
    };
    settings = {
      nfsd = {
        UDP = false;
        vers2 = false;
        vers3 = false;
        vers4 = true;
        "vers4.0" = false;
        "vers4.1" = false;
        "vers4.2" = true;
        rdma = true; # Remote Direct Memory Access
      };
    };
  };

  hardware.graphics = {
    package = hyprland-nixpkgs.mesa.drivers;
    enable32Bit = true;
    package32 = hyprland-nixpkgs.pkgsi686Linux.mesa.drivers;
  };

  system.stateVersion = "24.11";
}
