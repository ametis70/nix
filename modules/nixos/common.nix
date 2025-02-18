{
  pkgs,
  specialArgs,
  lib,
  ...
}:

{
  system.stateVersion = "${specialArgs.version}";
  system.copySystemConfiguration = false;

  nix.settings = {
    trusted-users = [ "${specialArgs.host.username}" ];
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

  programs.tmux.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
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

    e2fsprogs
    cloud-utils
    usbutils
    pciutils
  ];
}
