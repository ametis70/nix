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
    custom.programs.media.editing.notes.enable = lib.mkEnableOption "Enable note taking software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.editing.notes.enable = lib.mkDefault cfg.editing.enable;
    }
    (lib.mkIf cfg.editing.notes.enable {
    home.packages = with pkgs; [
      godot
    ];
    })
  ];
}
