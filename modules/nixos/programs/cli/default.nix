{ pkgs, inputs, ... }:

{
  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    tmux.enable = true;
    bat.enable = true;

    git = {
      enable = true;
      lfs.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    curl
    fd
    git
    tree
    dig
    mtr
    killall
    htop
    lsof
    jq
    ripgrep

    dmidecode
    likwid
    iperf
    tcpdump
    nmap
    edid-decode

    gzip
    zip
    unzip
    xz
    zstd
    p7zip

    e2fsprogs
    cloud-utils
    usbutils
    pciutils

    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
