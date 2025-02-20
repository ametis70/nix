{ ... }:
{
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
}
