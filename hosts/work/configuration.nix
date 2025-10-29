{ pkgs, host, ... }:

let
  chooseAppPkg = pkgs.writeShellScriptBin "choose-app" ''
    ls /Applications/ /Applications/Utilities/ /System/Applications/ /System/Applications/Utilities/ | \
        grep '\.app$' | \
        sed 's/\.app$//g' | \
        /opt/homebrew/bin/choose | \
        xargs -I {} open -a "{}.app"
  '';
in
{
  nix.enable = false;
  nix.package = pkgs.nix;
  users.users.${host.username}.home = "/Users/${host.username}";

  environment.systemPackages = [
    chooseAppPkg
  ];

  system.primaryUser = host.username;

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

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    taps = [
      "d12frosted/emacs-plus"
    ];
    brews = [
      "gettext"
      "choose-gui"
      "colima"
      "openssl"
      "asdf"
      "emacs-plus@30"
    ];
    casks = [
      "gimp"
      "inkscape"
      "jordanbaird-ice"
      "alt-tab"
      "redquits"
      "kitty"
      "moonlight"
      "cursor"
      "windsurf"
    ];
    masApps = {
      WireGuard = 1441195209;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 5;

  services.skhd = {
    enable = true;
    skhdConfig = ''
      cmd - d : ${chooseAppPkg}/bin/choose-app
    '';
  };
}
