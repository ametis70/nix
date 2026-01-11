{ lib, ... }:
{
  plugins.treesitter.settings.ensure_installed = lib.mkAfter [ "vue" "css" ];

  plugins.lsp.servers.vue_ls.enable = true;

  plugins.lsp.servers.vtsls.filetypes = lib.mkAfter [ "vue" ];

  plugins.lsp.preConfig = lib.mkAfter ''
    local vue_plugin = Nix.get_pkg_path("vue-language-server", "/node_modules/@vue/language-server")
    if vue_plugin ~= "" and vim.lsp.config.vtsls then
      local vtsls = vim.lsp.config.vtsls
      vtsls.settings = vtsls.settings or {}
      vtsls.settings.vtsls = vtsls.settings.vtsls or {}
      vtsls.settings.vtsls.tsserver = vtsls.settings.vtsls.tsserver or {}
      vtsls.settings.vtsls.tsserver.globalPlugins = vtsls.settings.vtsls.tsserver.globalPlugins or {}
      table.insert(vtsls.settings.vtsls.tsserver.globalPlugins, {
        name = "@vue/typescript-plugin",
        location = vue_plugin,
        languages = { "vue" },
        configNamespace = "typescript",
        enableForWorkspaceTypeScriptVersions = true,
      })
    end
  '';
}
