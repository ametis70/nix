{
  lib,
  config,
  pkgs,
  hyprland,
  host,
  ...
}:

let
  cfg = config.custom.greetd;
  hyprlandPackages = hyprland.${host.channel}.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.custom.greetd.enable = lib.mkEnableOption "greetd (tuigreet) login manager launching Hyprland";

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${lib.getExe pkgs.tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time --cmd 'uwsm start ${hyprlandPackages.hyprland}/share/wayland-sessions/hyprland.desktop'";
          user = host.username;
        };
      };
    };
  };
}
