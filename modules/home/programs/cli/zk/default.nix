{ lib, config, ... }:

let
  cfg = config.custom.programs.cli.zk;
in
{
  options.custom.programs.cli.zk = {
    enable = lib.mkEnableOption "Enable desktop theming";
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
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
