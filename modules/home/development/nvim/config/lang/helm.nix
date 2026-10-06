{ lib, ... }:
{
  plugins.treesitter.settings.ensure_installed = lib.mkAfter [ "helm" ];

  plugins.helm.enable = true;

  plugins.lsp.servers.helm_ls.enable = true;
}
