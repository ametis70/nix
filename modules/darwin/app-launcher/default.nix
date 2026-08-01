{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.custom.appLauncher;

  chooseAppPkg = pkgs.writeShellScriptBin "choose-app" ''
    ls /Applications/ /Applications/Utilities/ /System/Applications/ /System/Applications/Utilities/ | \
        grep '\.app$' | \
        sed 's/\.app$//g' | \
        /opt/homebrew/bin/choose | \
        xargs -I {} open -a "{}.app"
  '';
in
{
  options.custom.appLauncher.enable = lib.mkEnableOption "choose-app launcher bound to cmd-d via skhd";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ chooseAppPkg ];

    services.skhd = {
      enable = true;
      skhdConfig = ''
        cmd - d : ${chooseAppPkg}/bin/choose-app
      '';
    };
  };
}
