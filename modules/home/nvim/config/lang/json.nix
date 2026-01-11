{ lib, ... }:
{
  plugins.treesitter.settings.ensure_installed = lib.mkAfter [ "json5" ];

  plugins.schemastore.enable = true;

  plugins.lsp.servers.jsonls = {
    enable = true;
    settings = {
      json = {
        format = { enable = true; };
        validate = { enable = true; };
      };
    };
  };
}
