{ lib, pkgs, ... }:
{
  plugins.treesitter.settings.ensure_installed = lib.mkAfter [ "rust" "ron" ];

  plugins.crates = {
    enable = true;
    settings = {
      completion = {
        crates = { enabled = true; };
      };
      lsp = {
        enabled = true;
        actions = true;
        completion = true;
        hover = true;
      };
    };
  };

  plugins.rustaceanvim = {
    enable = true;
    settings = {
      server = {
        on_attach.__raw = ''
          function(_, bufnr)
            vim.keymap.set("n", "<leader>cR", function()
              vim.cmd.RustLsp("codeAction")
            end, { desc = "Code Action", buffer = bufnr })
            vim.keymap.set("n", "<leader>dr", function()
              vim.cmd.RustLsp("debuggables")
            end, { desc = "Rust Debuggables", buffer = bufnr })
          end
        '';
        default_settings = {
          "rust-analyzer" = {
            cargo = {
              allFeatures = true;
              loadOutDirsFromCheck = true;
              buildScripts = { enable = true; };
            };
            checkOnSave = true;
            diagnostics = { enable = true; };
            procMacro = { enable = true; };
            files = {
              exclude = [
                ".direnv"
                ".git"
                ".jj"
                ".github"
                ".gitlab"
                "bin"
                "node_modules"
                "target"
                "venv"
                ".venv"
              ];
              watcher = "client";
            };
          };
        };
      };
    };
  };

  plugins.lsp.servers = {
    rust_analyzer.enable = false;
    bacon_ls.enable = false;
  };

  extraPackages = with pkgs; [
    rust-analyzer
  ];

  plugins.neotest.settings.adapters = lib.mkAfter [
    { __raw = "require('rustaceanvim.neotest')" ; }
  ];
}
