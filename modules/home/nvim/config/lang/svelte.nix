{ lib, ... }:
{
  plugins.treesitter.settings.ensure_installed = lib.mkAfter [ "svelte" ];

  plugins.lsp.servers.svelte.enable = true;

  plugins.lsp.preConfig = lib.mkAfter ''
    local svelte_plugin = Nix.get_pkg_path("svelte-language-server", "/node_modules/typescript-svelte-plugin")
    if svelte_plugin ~= "" and vim.lsp.config.vtsls then
      local vtsls = vim.lsp.config.vtsls
      vtsls.settings = vtsls.settings or {}
      vtsls.settings.vtsls = vtsls.settings.vtsls or {}
      vtsls.settings.vtsls.tsserver = vtsls.settings.vtsls.tsserver or {}
      vtsls.settings.vtsls.tsserver.globalPlugins = vtsls.settings.vtsls.tsserver.globalPlugins or {}
      table.insert(vtsls.settings.vtsls.tsserver.globalPlugins, {
        name = "typescript-svelte-plugin",
        location = svelte_plugin,
        enableForWorkspaceTypeScriptVersions = true,
      })
    end
  '';

  extraConfigLua = ''
    local group = vim.api.nvim_create_augroup("nix_svelte_keys", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "svelte",
      callback = function(ev)
        vim.keymap.set("n", "<leader>co", function()
          vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" }, diagnostics = {} },
            apply = true,
          })
        end, { buffer = ev.buf, desc = "Organize Imports" })
      end,
    })
  '';
}
