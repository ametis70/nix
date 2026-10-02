{ config, lib, pkgs, ... }:

let
  cfg = config.services.steam-puck-bridge;
  package = pkgs.callPackage ./package.nix { };
in
{
  options.services.steam-puck-bridge.enable = lib.mkEnableOption "Steam Controller Puck bridge";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ package ];

    services.udev.packages = [ package ];

    # This is deliberately a user unit: the daemon needs the active seat's
    # uaccess ACLs on hidraw and /dev/uinput, and must not run as root.
    systemd.user.services.steam-puck-bridge = {
      description = "Steam Controller Puck bridge";
      wantedBy = [ "default.target" ];
      unitConfig = {
        After = "graphical-session.target";
        ConditionPathExists = "/dev/uinput";
      };
      serviceConfig = {
        ExecStart = "${package}/bin/steam-puck-bridge";
        Restart = "on-failure";
        RestartSec = 3;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        PrivateTmp = true;
      };
    };
  };
}
