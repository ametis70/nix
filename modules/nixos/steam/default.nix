{ lib, config, ... }:

let
  cfg = config.custom.steam;
in
{
  options.custom.steam.enable = lib.mkEnableOption "Steam with a gamescope session";

  # The unfree allowlist for steam packages stays in the host's
  # nixpkgs.config.allowUnfreePredicate (it aggregates all of a host's unfree
  # packages into one predicate, which cannot be merged across modules).
  config = lib.mkIf cfg.enable {
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
  };
}
