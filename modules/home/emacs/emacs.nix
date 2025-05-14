{
  pkgs,
  config,
  lib,
  ...
}:

{
  home.sessionVariables = {
    DOOMDIR = "${config.xdg.configHome}/doom";
    EMACSDIR = "${config.xdg.configHome}/emacs";
    DOOMLOCALDIR = "${config.xdg.dataHome}/doom";
    DOOMPROFILELOADFILE = "${config.xdg.stateHome}/doom-profiles-load.el";
  };

  home.sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];

  programs.emacs = {
    enable = lib.mkIf pkgs.stdenv.hostPlatform.isLinux true;
    package = pkgs.emacs;
    extraPackages = with pkgs; [
      ripgrep
      fd
      emacs-all-the-icons-fonts
    ];
  };

  xdg.configFile."emacs".source = builtins.fetchGit {
    url = "https://github.com/doomemacs/doomemacs.git";
    rev = "e614ffbda8b278bc9fd9a9cb3a836d636b1091e6";
  };

  xdg.configFile."doom".source = ./doom;
}
