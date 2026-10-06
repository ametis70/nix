{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.custom.programs.media;
in
{
  options = {
    custom.programs.media.viewing.audio.enable = lib.mkEnableOption "Enable audio playback software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.viewing.audio.enable = lib.mkDefault cfg.viewing.enable;
    }
    (lib.mkIf cfg.viewing.audio.enable {
    programs.mpv = {
      enable = true;
    };

    home.packages = with pkgs; [
      vlc
    ];

    xdg.mimeApps = {
      defaultApplications =
        let
          mpv = [ "mpv.desktop" ];
        in
        lib.genAttrs [
          # mpv audio
          "audio/mpeg"
          "audio/mp4"
          "audio/aac"
          "audio/flac"
          "audio/ogg"
          "audio/vorbis"
          "audio/opus"
          "audio/wav"
          "audio/x-wav"
          "audio/webm"
          "audio/x-matroska"
          "audio/x-ms-wma"
          "audio/x-aiff"
          "audio/midi"
          "audio/x-midi"

          # playlists
          "audio/x-mpegurl"
          "application/x-mpegurl"
          "application/vnd.apple.mpegurl"
          "audio/x-scpls"
        ] (_: mpv);
    };
    })
  ];
}
