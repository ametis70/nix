{
  pkgs,
  lib,
  hyprland,
  host,
  ...
}:

let
  hyprland-nixpkgs =
    hyprland.${host.channel}.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
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
    hostName = host.hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };

  systemd.services.nix-daemon.serviceConfig = {
    MemoryAccounting = true;
    MemoryMax = "85%";
    OOMScoreAdjust = 500;
  };

  hardware.graphics = {
    package = hyprland-nixpkgs.mesa.drivers;
    enable32Bit = true;
    package32 = hyprland-nixpkgs.pkgsi686Linux.mesa.drivers;
  };

  custom.k3s-client.enable = true;

  system.stateVersion = "24.11";
}
