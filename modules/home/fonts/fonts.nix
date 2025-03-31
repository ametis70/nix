{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-lgc-plus
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    iosevka
    pkgs-unstable.nerd-fonts.symbols-only
    pkgs-unstable.nerd-fonts.hack
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Noto Serif" ];
      emoji = [ "Noto Color Emoji" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "Iosevka" ];
    };
  };
}
