{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.custom.development.emacs;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  options.custom.development.emacs = {
    enable = lib.mkEnableOption "Enable OpenCode";
  };

  config = lib.mkIf cfg.enable {
    home = {
      sessionVariables = {
        DOOMDIR = "${config.xdg.configHome}/doom";
        EMACSDIR = "${config.xdg.configHome}/emacs";
        DOOMLOCALDIR = "${config.xdg.dataHome}/doom";
        DOOMPROFILELOADFILE = "${config.xdg.stateHome}/doom-profiles-load.el";

      };
      sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];
      packages = lib.optionals isLinux (
        with pkgs;
        [
          ripgrep
          fd
          emacs-all-the-icons-fonts
        ]
      );
    };

    programs.emacs = {
      enable = lib.mkIf isLinux true;
      package = pkgs.emacs;
    };

    xdg.configFile."emacs".source = builtins.fetchGit {
      url = "https://github.com/doomemacs/doomemacs.git";
      rev = "e614ffbda8b278bc9fd9a9cb3a836d636b1091e6";
    };

    xdg.configFile."doom".source = ./doom;
  };
}
