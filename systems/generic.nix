{ pkgs, ... }:

{
  home.packages = with pkgs; [
    timewarrior
    taskwarrior
    taskwarrior-tui
    pass
    fd
    curl
    jq
    asdf-vm
    ranger
    (nerdfonts.override { fonts = [ "Iosevka" ]; })
  ];

  fonts.fontconfig.enable = true;
}
