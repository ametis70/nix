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
    custom.programs.media.viewing.video.enable = lib.mkEnableOption "Enable video playback software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.viewing.video.enable = lib.mkDefault cfg.viewing.enable;
    }
    (lib.mkIf cfg.viewing.video.enable {
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
          # mpv video
          "video/mp4"
          "video/x-matroska"
          "video/webm"
          "video/x-msvideo"
          "video/quicktime"
          "video/x-ms-wmv"
          "video/mpeg"
          "video/ogg"
          "video/3gpp"
          "video/3gpp2"
          "video/mp2t"
          "video/x-flv"
          "video/dv"

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
