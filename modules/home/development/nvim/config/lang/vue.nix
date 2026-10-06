{ lib, pkgs, ... }:
{
  plugins.treesitter.settings.ensure_installed = lib.mkAfter [
    "vue"
    "css"
  ];

  # NOTE: diasble temporarily because of cache miss
  plugins.lsp.servers.vue_ls.enable = false;
}
