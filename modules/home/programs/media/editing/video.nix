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
    custom.programs.media.editing.video.enable = lib.mkEnableOption "Enable video editing software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.editing.video.enable = lib.mkDefault cfg.editing.enable;
    }
    (lib.mkIf cfg.editing.video.enable {
      programs.obs-studio = {
        enable = true;
      };

      home.packages = with pkgs; [
        ffmpeg
      ];
    })
  ];
}
