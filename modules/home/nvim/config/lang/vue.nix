{ lib, pkgs, ... }:
{
  plugins.treesitter.settings.ensure_installed = lib.mkAfter [
    "vue"
    "css"
  ];

  plugins.lsp.servers.vue_ls.enable = true;

  plugins.lsp.servers.vtsls = {
    filetypes = lib.mkAfter [ "vue" ];

    settings = {
      vtsls = {
        tsserver = {
          globalPlugins = lib.mkAfter [
            {
              name = "@vue/typescript-plugin";
              location = "${pkgs.vue-language-server}/lib/language-tools/node_modules/.pnpm/node_modules/@vue/typescript-plugin";
              languages = [ "vue" ];
              configNamespace = "typescript";
              enableForWorkspaceTypeScriptVersions = true;
            }
          ];
        };
      };
    };
  };

  extraPackages = with pkgs; [
    vue-language-server
  ];
}
