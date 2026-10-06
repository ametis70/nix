{ lib, ... }:
{
  plugins.treesitter.settings.ensure_installed = lib.mkAfter [
    "git_config"
    "gitcommit"
    "git_rebase"
    "gitignore"
    "gitattributes"
  ];

  plugins.blink-cmp-git.enable = true;
  plugins.blink-cmp.settings.sources = {
    default = lib.mkAfter [ "git" ];
    providers.git = {
      name = "git";
      module = "blink-cmp-git";
    };
  };
}
