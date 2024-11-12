{ pkgs, specialArgs, ... }:

{
  system.stateVersion = "${specialArgs.version}";
  system.copySystemConfiguration = false;

  nix.settings = {
    trusted-users = [ "${specialArgs.host.username}" ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
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
