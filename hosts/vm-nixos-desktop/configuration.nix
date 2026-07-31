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
    ./hardware-configuration.nix
  ];

  custom = {
    guest.enable = true;
    printing.enable = true;
    scanning.enable = true;
    docker.enable = true;
    pipewire.enable = true;
    greetd.enable = true;
    hyprland.enable = true;
    keyring.enable = true;
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "imagescan-plugin-networkscan"
      "via"
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

  services.blueman.enable = true;

  custom.crealityPrint.enable = false;

  # programs.appimage = {
  #   enable = true;
  #   binfmt = true;
  #   package = pkgs.appimage-run.override {
  #     extraPkgs =
  #       pkgs: with pkgs; [
  #         gst_all_1.gst-plugins-bad
  #         webkitgtk_4_0
  #       ];
  #   };
  # };

  hardware.keyboard.qmk.enable = true;
  environment.systemPackages = with pkgs; [
    via
    calibre
    imv
  ];
  services.udev.packages = with pkgs; [ via ];

  custom.nfs.enable = true;

  hardware.bluetooth.enable = true;

  system.stateVersion = "24.11";
}
