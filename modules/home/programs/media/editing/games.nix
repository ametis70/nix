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
    custom.programs.media.editing.games.enable = lib.mkEnableOption "Enable game making software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.editing.games.enable = lib.mkDefault cfg.editing.enable;
    }
    (lib.mkIf cfg.editing.games.enable {
    home.packages = with pkgs; [
      godot
    ];
    })
  ];
}
