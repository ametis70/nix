{
  pkgs,
  config,
  lib,
  host,
  inputs,
  ...
}:

# Base NixOS system: nix settings, boot/locale/console defaults, core programs
# and system packages that every host got via the old common.nix. The five
# sub-modules common.nix used to import (k3s-server, creality-print, nfs, nut,
# catppuccin) are now provided by the aggregator and toggled per host.
let
  cfg = config.custom.base;
in
{
  options.custom.base.enable = lib.mkEnableOption "base NixOS system configuration" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    system.copySystemConfiguration = false;

    nix.settings = {
      trusted-users = [ "${host.username}" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    boot.loader = {
      efi.canTouchEfiVariables = lib.mkDefault true;
      systemd-boot.enable = lib.mkDefault true;
    };

    systemd.targets = {
      sleep.enable = lib.mkDefault false;
      suspend.enable = lib.mkDefault false;
      hibernate.enable = lib.mkDefault false;
      hybrid-sleep.enable = lib.mkDefault false;
    };

    time.timeZone = "America/Argentina/Buenos_Aires";

    i18n.defaultLocale = "en_US.UTF-8";

    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    programs.mosh.enable = true;

    programs.tmux.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
    };

    programs.git = {
      enable = true;
      lfs.enable = true;
    };

    environment.systemPackages = with pkgs; [
      curl
      fd
      fzf
      git
      tree
      dig
      mtr
      killall
      htop
      lsof

      gzip
      zip
      xz
      zstd
      p7zip

      e2fsprogs
      cloud-utils
      usbutils
      pciutils

      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
