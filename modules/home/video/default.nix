{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.custom.video;
in
{
  options.custom.video.enable = lib.mkEnableOption "video tooling (ffmpeg, obs-studio, mpv)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ffmpeg
      obs-studio
      mpv
    ];
  };
}
