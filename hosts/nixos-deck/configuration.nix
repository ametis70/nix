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

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "steamdeck-hw-theme"
      "steam-run"
      "steam-original"
      "steam"
      "steam-jupiter-unwrapped"
    ];

  jovian.steam = {
    enable = true;
    autoStart = true;
    desktopSession = "hyprland";
    user = specialArgs.host.username;
  };

  jovian.devices.steamdeck.enable = true;

  systemd.targets = {
    sleep.enable = true;
    suspend.enable = true;
  };

  networking = {
    hostName = specialArgs.host.hostname;
    networkmanager.enable = true;
    firewall.enable = false;
  };
}
