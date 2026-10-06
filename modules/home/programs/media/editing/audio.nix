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
    custom.programs.media.editing.audio.enable = lib.mkEnableOption "Enable audio editing software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.editing.audio.enable = lib.mkDefault cfg.editing.enable;
    }
    (lib.mkIf cfg.editing.audio.enable {
    home.packages = with pkgs; [
      ffmpeg
      audacity
    ];

    xdg.mimeApps = {
      defaultApplications =
        let
          audacity = [ "audacity.desktop" ];
        in
        lib.genAttrs [
          "application/x-audacity-project"
          "application/x-audacity-project3"
        ] (_: audacity);
    };
    })
  ];
}
