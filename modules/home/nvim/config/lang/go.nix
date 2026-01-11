{ lib, pkgs, ... }:
{
  plugins.treesitter.settings.ensure_installed = lib.mkAfter [
    "go"
    "gomod"
    "gowork"
    "gosum"
  ];

  plugins.lsp.servers.gopls = {
    enable = true;
    settings = {
      gopls = {
        gofumpt = true;
        codelenses = {
          gc_details = false;
          generate = true;
          regenerate_cgo = true;
          run_govulncheck = true;
          test = true;
          tidy = true;
          upgrade_dependency = true;
          vendor = true;
        };
        hints = {
          assignVariableTypes = true;
          compositeLiteralFields = true;
          compositeLiteralTypes = true;
          constantValues = true;
          functionTypeParameters = true;
          parameterNames = true;
          rangeVariableTypes = true;
        };
        analyses = {
          nilness = true;
          unusedparams = true;
          unusedwrite = true;
          useany = true;
        };
        usePlaceholders = true;
        completeUnimported = true;
        staticcheck = true;
        directoryFilters = [
          "-.git"
          "-.vscode"
          "-.idea"
          "-.vscode-test"
          "-node_modules"
        ];
        semanticTokens = true;
      };
    };
  };

  plugins.conform-nvim.settings.formatters_by_ft.go = [
    "goimports"
    "gofumpt"
  ];
  plugins.lint.lintersByFt.go = [ "golangcilint" ];

  extraPackages = with pkgs; [
    gotools
    gofumpt
    golangci-lint
  ];

  plugins.dap-go = {
    enable = true;
    settings = { };
  };

  plugins.neotest.adapters.golang = {
    enable = true;
    settings = {
      dap_go_enabled = true;
    };
  };

  plugins.mini-icons.settings = {
    file = {
      ".go-version" = {
        glyph = "";
        hl = "MiniIconsBlue";
      };
    };
    filetype = {
      gotmpl = {
        glyph = "󰟓";
        hl = "MiniIconsGrey";
      };
    };
  };

  extraConfigLua = ''
    Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
      if not client.server_capabilities.semanticTokensProvider then
        local semantic = client.config.capabilities.textDocument.semanticTokens
        client.server_capabilities.semanticTokensProvider = {
          full = true,
          legend = {
            tokenTypes = semantic.tokenTypes,
            tokenModifiers = semantic.tokenModifiers,
          },
          range = true,
        }
      end
    end)
  '';
}
