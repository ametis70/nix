{
  config,
  lib,
  ...
}:

let
  cfg = config.custom.programs.media;
in
{
  options.custom.programs.media = {
    enable = lib.mkEnableOption "Enable media viewing and editing software";
    mime = lib.mkOption {
      description = "Enable MIME types handling for media software";
      default = true;
      type = lib.types.bool;
    };
    viewing.enable = lib.mkEnableOption "Enable media viewing software";
    editing.enable = lib.mkEnableOption "Enable media editing software";
  };

  imports = [
    ./viewing/audio.nix
    ./viewing/documents.nix
    ./viewing/pictures.nix
    ./viewing/video.nix

    ./editing/audio.nix
    ./editing/cad.nix
    ./editing/design.nix
    ./editing/documents.nix
    ./editing/drawing.nix
    ./editing/games.nix
    ./editing/modeling.nix
    ./editing/notes.nix
    ./editing/pdf.nix
    ./editing/photos.nix
    ./editing/video.nix
  ];

  config = lib.mkMerge [
    {
      custom.programs.media.viewing.enable = lib.mkDefault cfg.enable;
      custom.programs.media.editing.enable = lib.mkDefault cfg.enable;
    }
    (lib.mkIf cfg.enable {
      xdg.mimeApps.enable = cfg.mime;
    })
  ];
}
