{
  pkgs,
  lib,
  config,
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
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/emulation

    ./hardware-configuration.nix

    ./edid
  ];

  custom.emulation.enable = true;

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) (
      [
        "discord"
        "imagescan-plugin-networkscan"
        "via"
      ]
      ++ config.custom.emulation.allowedUnfreePackages
    );

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

  custom.programs.creality-print.enable = false;

  hardware.keyboard.qmk.enable = true;
  environment.systemPackages = with pkgs; [
    via
  ];

  services.gvfs.enable = true;

  services.udev.packages = with pkgs; [ via ];

  # The Sofle's System Control USB interface (if02) is tagged ID_INPUT_JOYSTICK=1 by
  # the kernel because QMK exposes ABS_MISC/HAT axes on it. This makes RetroArch pick
  # it up as a gamepad. Clear the joystick tag so only its keyboard/media capabilities
  # are visible to joystick-reading applications.
  services.udev.extraRules = ''
    SUBSYSTEM=="input", \
      ENV{ID_VENDOR_ID}=="fc32", \
      ENV{ID_MODEL_ID}=="0287", \
      ENV{ID_USB_INTERFACE_NUM}=="02", \
      ENV{ID_INPUT_JOYSTICK}="", \
      ENV{ID_INPUT}="1", \
      ENV{ID_INPUT_KEY}="1"
  '';

  custom.services.nfs.enable = true;

  system.stateVersion = "24.11";
}
