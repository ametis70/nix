{
  pkgs,
  lib,
  config,
  host,
  ...
}:

let
  cfg = config.custom.gaming.steam;
in
{
  options.custom.gaming.steam = {
    enable = lib.mkEnableOption "Enable Steam";
    jovian = {
      enable = lib.mkEnableOption "Use Jovian-Nix-OS";
      autoStart = lib.mkEnableOption "Autostart steam on Jovian-NixOS";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs = {
          gamemode = {
            enable = true;
          };
        };

        environment.systemPackages = with pkgs; [
          protonup-ng
          mangohud
        ];

        environment.sessionVariables = {
          STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
        };

        nixpkgs.config.allowUnfreePackages = [
          "steam"
          "steam-original"
          "steam-unwrapped"
          "steam-run"
          "steamdeck-hw-theme"
          "steam-jupiter-unwrapped"
        ];
      }
      (lib.mkIf (!cfg.jovian.enable) {
        programs = {
          steam = {
            enable = true;
            gamescopeSession.enable = true;
          };
          gamescope.enable = true;
        };
      })
      (lib.mkIf cfg.jovian.enable {
        jovian = {
          steam = {
            enable = true;
            autoStart = cfg.jovian.autoStart;
            desktopSession = if cfg.jovian.autoStart then "plasma" else null;
            user = host.username;
          };
        };
      })
    ]
  );

}
