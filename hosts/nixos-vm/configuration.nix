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
    package = hyprland-nixpkgs.mesa;
    enable32Bit = true;
    package32 = hyprland-nixpkgs.pkgsi686Linux.mesa;
  };

  custom.k3s-client.enable = true;

  custom.programs.creality-print.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs =
        pkgs: with pkgs; [
          gst_all_1.gst-plugins-bad
          webkitgtk_4_0
        ];
    };
  };

  custom.services.nfs.enable = true;

  environment.systemPackages = with pkgs; [
    transmission_4-qt
  ];

  system.stateVersion = "24.11";
}
