{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpeg
    obs-studio
    mpv
  ];
}
