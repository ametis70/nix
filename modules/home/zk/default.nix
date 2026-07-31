{ lib, config, ... }:

let
  cfg = config.custom.zk;
in
{
  options.custom.zk.enable = lib.mkEnableOption "zk notebook";

  config = lib.mkIf cfg.enable {
    programs.zsh.sessionVariables = {
      ZK_NOTEBOOK_DIR = "$HOME/Documents/Notes";
    };

    programs.zk = {
      enable = true;
      settings = {
        notebook = {
          dir = "~/Documents/Notes";
        };
      };
    };
  };
}
