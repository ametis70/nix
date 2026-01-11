{
  plugins.schemastore.enable = true;

  plugins.lsp.servers.yamlls = {
    enable = true;
    settings = {
      redhat = {
        telemetry = {
          enabled = false;
        };
      };
      yaml = {
        keyOrdering = false;
        format = {
          enable = true;
        };
        validate = true;
        schemaStore = {
          enable = false;
          url = "";
        };
      };
    };
    extraOptions = {
      capabilities = {
        textDocument = {
          foldingRange = {
            dynamicRegistration = false;
            lineFoldingOnly = true;
          };
        };
      };
    };
  };
}
