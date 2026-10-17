{
  pkgs,
  lib,
  config,
  options,
  host,
  ...
}:

let
  cfg = config.custom.gaming.steam;
  hasJovianSteam = builtins.hasAttr "jovian" options && builtins.hasAttr "steam" options.jovian;
  hasJovianSteamos = hasJovianSteam && builtins.hasAttr "steamos" options.jovian;
in
{
  options.custom.gaming.steam = {
    enable = lib.mkEnableOption "Enable Steam";
    jovian = {
      enable = lib.mkEnableOption "Use Jovian-Nix-OS";
      autoStart = lib.mkEnableOption "Autostart steam on Jovian-NixOS";
      sessionWrapper = lib.mkEnableOption "Jovian Steam session switch wrapper";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = !cfg.jovian.enable || hasJovianSteam;
            message = "custom.gaming.steam.jovian.enable requires the Jovian-NixOS module.";
          }
        ];

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
      (lib.mkIf (!cfg.jovian.enable || !hasJovianSteam) {
        programs = {
          steam = {
            enable = true;
            gamescopeSession.enable = true;
          };
          gamescope.enable = true;
        };
      })
      (lib.mkIf (cfg.jovian.enable && hasJovianSteam) {
        jovian.steam = {
          enable = true;
          autoStart = cfg.jovian.autoStart;
          desktopSession = if cfg.jovian.autoStart then "plasma" else null;
          user = host.username;
        };
      })
      (lib.mkIf (cfg.jovian.enable && cfg.jovian.autoStart && hasJovianSteamos) {
        nixpkgs.overlays = [
          (final: prev: {
            steamos-manager = prev.steamos-manager.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [ ./patches/steamos-manager-jobmode-replace.patch ];
            });
          })
        ];

        services.displayManager = {
          defaultSession = lib.mkDefault "plasma";
          autoLogin.enable = lib.mkForce false;
          sddm = {
            enable = true;
            wayland.enable = true;
            settings.Autologin = {
              Relogin = true;
              User = host.username;
            };
          };
        };

        systemd.tmpfiles.rules =
          let
            desktops = config.services.displayManager.sessionData.desktops;
          in
          [
            "L+ /usr/share/wayland-sessions - - - - ${desktops}/share/wayland-sessions"
            "L+ /usr/share/xsessions - - - - ${desktops}/share/xsessions"
            "f /etc/sddm.conf.d/zz-steamos-autologin.conf 0644 root root - [Autologin]\\nSession=gamescope-wayland.desktop\\n"
          ];

        jovian.steamos.useSteamOSConfig = true;
      })
      (lib.mkIf (cfg.jovian.sessionWrapper && hasJovianSteam) {
        environment.systemPackages = [
          (pkgs.writeShellScriptBin "steamos-session-select" ''
            # Stop the Jovian gamescope-session target.
            # This causes start-gamescope-session to exit naturally (its --wait returns),
            # which launchscoped detects and uses to relaunch the launcher UI.
            systemctl --user stop gamescope-session.target 2>/dev/null || true
          '')
        ];
      })
    ]
  );

}
