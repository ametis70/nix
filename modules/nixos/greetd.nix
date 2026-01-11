{
  pkgs,
  lib,
  hyprland,
  host,
  ...
}:

let
  hyprlandPackages = hyprland.${host.channel}.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time --cmd 'uwsm start ${hyprlandPackages.hyprland}/share/wayland-sessions/hyprland.desktop'";
        user = host.username;
      };
    };
  };
}
