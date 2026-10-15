{
  pkgs,
  config,
  lib,
  host,
  ...
}:

let
  cfg = config.custom.desktop.dm.greetd;
in
{
  options = {
    custom.desktop.dm.greetd.enable = lib.mkEnableOption "Enable greetd display manager";
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${lib.getExe pkgs.tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time --cmd 'uwsm start -- hyprland.desktop'";
          user = host.username;
        };
      };
    };
  };
}
