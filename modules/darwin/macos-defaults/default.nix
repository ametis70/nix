{ lib, config, ... }:

let
  cfg = config.custom.macosDefaults;
in
{
  options.custom.macosDefaults.enable =
    lib.mkEnableOption "macOS system defaults (keyboard, dock, finder, key repeat)";

  config = lib.mkIf cfg.enable {
    system = {
      activationScripts.activateSettings.text = ''
        # activateSettings -u will reload the settings from the database and apply
        # them to the current session, so we do not need to logout and login again
        # to make the changes take effect.
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';

      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };

      defaults = {
        menuExtraClock.ShowSeconds = true;

        NSGlobalDomain = {
          # keyboard navigation in dialogs
          AppleKeyboardUIMode = 3;

          # disable press-and-hold for keys in favor of key repeat
          ApplePressAndHoldEnabled = false;

          # fast key repeat rate when hold
          KeyRepeat = 2;
          InitialKeyRepeat = 15;
        };

        dock = {
          tilesize = 64;
          orientation = "left";
          autohide = true;
        };

        finder = {
          ShowStatusBar = true;
          ShowPathbar = true;
          FXPreferredViewStyle = "Nlsv";
          _FXShowPosixPathInTitle = true;
        };
      };
    };
  };
}
