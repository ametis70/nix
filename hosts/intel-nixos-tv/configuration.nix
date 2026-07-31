{
  pkgs,
  specialArgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ./edid
  ];

  networking = {
    hostName = specialArgs.host.hostname;
    useDHCP = true;
  };

  custom = {
    swapfile.enable = true;
    plasma.enable = true;
    intelGraphics.enable = true;
    steam.enable = true;
    nfs.enable = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
    ];

  environment.systemPackages = with pkgs; [
    ncpamixer
    edid-decode
    retroarch-joypad-autoconfig
    retroarch-assets
    retroarch-free
    kodi-wayland
    libcec
    moonlight-qt
    ungoogled-chromium
  ];

  users.users.ametis70.extraGroups = [ "dialout" ];

  system.stateVersion = "25.05";
}
