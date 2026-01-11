{
  plugins.lsp = {
    enable = true;
    inlayHints = true;
    servers = {
      "*" = {
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true;
              willRename = true;
            };
          };
        };
      };

      lua_ls = {
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false;
            };
            codeLens = {
              enable = true;
            };
            completion = {
              callSnippet = "Replace";
            };
            doc = {
              privateName = [ "^_" ];
            };
            hint = {
              enable = true;
              setType = false;
              paramType = true;
              paramName = "Disable";
              semicolon = "Disable";
              arrayIndex = "Disable";
            };
          };
        };
      };
    };
  };

  plugins.neoconf = {
    enable = true;
    settings = { };
  };

  plugins.fidget = {
    enable = true;
    settings = { };
  };

  plugins.lsp.keymaps.extra = [
    {
      key = "<leader>cl";
      action.__raw = "function() Snacks.picker.lsp_config() end";
      options.desc = "Lsp Info";
    }
    {
      key = "gd";
      action.__raw = "function() Snacks.picker.lsp_definitions() end";
      options.desc = "Goto Definition";
    }
    {
      key = "gr";
      action.__raw = "function() Snacks.picker.lsp_references() end";
      options.desc = "References";
    }
    {
      key = "gI";
      action.__raw = "function() Snacks.picker.lsp_implementations() end";
      options.desc = "Goto Implementation";
    }
    {
      key = "gy";
      action.__raw = "function() Snacks.picker.lsp_type_definitions() end";
      options.desc = "Goto T[y]pe Definition";
    }
    {
      key = "gD";
      action = "<cmd>lua vim.lsp.buf.declaration()<cr>";
      options.desc = "Goto Declaration";
    }
    {
      key = "K";
      action = "<cmd>lua vim.lsp.buf.hover()<cr>";
      options.desc = "Hover";
    }
    {
      key = "gK";
      action = "<cmd>lua vim.lsp.buf.signature_help()<cr>";
      options.desc = "Signature Help";
    }
    {
      key = "<c-k>";
      mode = "i";
      action = "<cmd>lua vim.lsp.buf.signature_help()<cr>";
      options.desc = "Signature Help";
    }
    {
      key = "<leader>ca";
      mode = [ "n" "x" ];
      action = "<cmd>lua vim.lsp.buf.code_action()<cr>";
      options.desc = "Code Action";
    }
    {
      key = "<leader>cc";
      mode = [ "n" "x" ];
      action = "<cmd>lua vim.lsp.codelens.run()<cr>";
      options.desc = "Run Codelens";
    }
    {
      key = "<leader>cC";
      mode = [ "n" ];
      action = "<cmd>lua vim.lsp.codelens.refresh()<cr>";
      options.desc = "Refresh & Display Codelens";
    }
    {
      key = "<leader>cR";
      action.__raw = "function() Snacks.rename.rename_file() end";
      options.desc = "Rename File";
    }
    {
      key = "<leader>cr";
      action = "<cmd>lua vim.lsp.buf.rename()<cr>";
      options.desc = "Rename";
    }
    {
      key = "<leader>cA";
      action.__raw = ''
        function()
          vim.lsp.buf.code_action({ context = { only = { "source" } } })
        end
      '';
      options.desc = "Source Action";
    }
    {
      key = "<leader>ss";
      action.__raw = "function() Snacks.picker.lsp_symbols({ filter = Nix.kind_filter }) end";
      options.desc = "LSP Symbols";
    }
    {
      key = "<leader>sS";
      action.__raw = "function() Snacks.picker.lsp_workspace_symbols({ filter = Nix.kind_filter }) end";
      options.desc = "LSP Workspace Symbols";
    }
    {
      key = "gai";
      action.__raw = "function() Snacks.picker.lsp_incoming_calls() end";
      options.desc = "Calls Incoming";
    }
    {
      key = "gao";
      action.__raw = "function() Snacks.picker.lsp_outgoing_calls() end";
      options.desc = "Calls Outgoing";
    }
    {
      key = "]]";
      action.__raw = "function() Snacks.words.jump(vim.v.count1) end";
      options.desc = "Next Reference";
    }
    {
      key = "[[";
      action.__raw = "function() Snacks.words.jump(-vim.v.count1) end";
      options.desc = "Prev Reference";
    }
    {
      key = "<a-n>";
      action.__raw = "function() Snacks.words.jump(vim.v.count1, true) end";
      options.desc = "Next Reference";
    }
    {
      key = "<a-p>";
      action.__raw = "function() Snacks.words.jump(-vim.v.count1, true) end";
      options.desc = "Prev Reference";
    }
  ];

  extraConfigLua = ''
    local icons = Nix.icons.diagnostics

    vim.diagnostic.config({
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
      },
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = icons.Error,
          [vim.diagnostic.severity.WARN] = icons.Warn,
          [vim.diagnostic.severity.HINT] = icons.Hint,
          [vim.diagnostic.severity.INFO] = icons.Info,
        },
      },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("nix_lsp_inlay", { clear = true }),
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if ft == "vue" then
          return
        end
        if vim.lsp.inlay_hint then
          vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end
      end,
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("nix_lsp_folds", { clear = true }),
      callback = function()
        if vim.lsp.foldexpr then
          vim.opt.foldmethod = "expr"
          vim.opt.foldexpr = "v:lua.vim.lsp.foldexpr()"
        end
      end,
    })
  '';
}
