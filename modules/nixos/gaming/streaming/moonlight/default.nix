{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.gaming.streaming.moonlight;
in
{
  options.custom.gaming.streaming.moonlight.enable =
    lib.mkEnableOption "Moonlight game streaming client";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.moonlight-qt ];
  };
}
