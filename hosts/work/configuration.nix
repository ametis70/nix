{ pkgs, specialArgs, ... }:

let
  choosePasswordPkg = pkgs.writeShellScriptBin "choose-pass" ''
    find "$HOME/.password-store" -type f -name '*.gpg' | \
      sed "s|.*/\.password-store/||; s|\.gpg$||" | \
      /opt/homebrew/bin/choose | \
      xargs -r -I{} pass show -c {}
  '';

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
  users.users.${specialArgs.host.username}.home = "/Users/${specialArgs.host.username}";

  environment.systemPackages = [
    choosePasswordPkg
    chooseAppPkg
  ];

  system = {
    activationScripts.postUserActivation.text = ''
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
    brews = [
      "choose-gui"
    ];
    casks = [
      "alt-tab"
      "redquits"
      "kitty"
    ];
  };

  security.pam.enableSudoTouchIdAuth = true;

  system.stateVersion = 5;

  services.skhd = {
    enable = true;
    skhdConfig = ''
      cmd + shift - p : ${choosePasswordPkg}/bin/choose-pass
      cmd - d : ${chooseAppPkg}/bin/choose-app
    '';
  };
}
