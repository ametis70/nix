{ lib, pkgs, ... }:
{
  plugins.lsp.servers.ts_ls.enable = false;

  plugins.lsp.servers.vtsls = {
    enable = true;
    filetypes = [
      "javascript"
      "javascriptreact"
      "javascript.jsx"
      "typescript"
      "typescriptreact"
      "typescript.tsx"
    ];
    settings = {
      complete_function_calls = true;
      vtsls = {
        enableMoveToFileCodeAction = true;
        autoUseWorkspaceTsdk = true;
        experimental = {
          maxInlayHintLength = 30;
          completion = {
            enableServerSideFuzzyMatch = true;
          };
        };
      };
      typescript = {
        updateImportsOnFileMove = {
          enabled = "always";
        };
        suggest = {
          completeFunctionCalls = true;
        };
        inlayHints = {
          enumMemberValues = {
            enabled = true;
          };
          functionLikeReturnTypes = {
            enabled = true;
          };
          parameterNames = {
            enabled = "literals";
          };
          parameterTypes = {
            enabled = true;
          };
          propertyDeclarationTypes = {
            enabled = true;
          };
          variableTypes = {
            enabled = false;
          };
        };
      };
    };
  };

  plugins.mini-icons.settings.file = {
    ".eslintrc.js" = {
      glyph = "󰱺";
      hl = "MiniIconsYellow";
    };
    ".node-version" = {
      glyph = "";
      hl = "MiniIconsGreen";
    };
    ".prettierrc" = {
      glyph = "";
      hl = "MiniIconsPurple";
    };
    ".yarnrc.yml" = {
      glyph = "";
      hl = "MiniIconsBlue";
    };
    "eslint.config.js" = {
      glyph = "󰱺";
      hl = "MiniIconsYellow";
    };
    "package.json" = {
      glyph = "";
      hl = "MiniIconsGreen";
    };
    "tsconfig.json" = {
      glyph = "";
      hl = "MiniIconsAzure";
    };
    "tsconfig.build.json" = {
      glyph = "";
      hl = "MiniIconsAzure";
    };
    "yarn.lock" = {
      glyph = "";
      hl = "MiniIconsBlue";
    };
  };

  plugins.lsp.preConfig = lib.mkAfter ''
    if vim.lsp.config.denols and vim.lsp.config.vtsls then
      local resolve = function(server)
        local markers, root_dir = vim.lsp.config[server].root_markers, vim.lsp.config[server].root_dir
        vim.lsp.config(server, {
          root_dir = function(bufnr, on_dir)
            local is_deno = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" }) ~= nil
            if is_deno == (server == "denols") then
              if root_dir then
                return root_dir(bufnr, on_dir)
              elseif type(markers) == "table" then
                local root = vim.fs.root(bufnr, markers)
                return root and on_dir(root)
              end
            end
          end,
        })
      end
      resolve("denols")
      resolve("vtsls")
    end

    if vim.lsp.config.vtsls and vim.lsp.config.vtsls.settings and vim.lsp.config.vtsls.settings.typescript then
      local vtsls = vim.lsp.config.vtsls
      vtsls.settings.javascript = vim.tbl_deep_extend(
        "force",
        {},
        vtsls.settings.typescript,
        vtsls.settings.javascript or {}
      )
    end
  '';

  extraPackages = with pkgs; [
    typescript
    eslint_d
  ];

  extraConfigLua = ''
    Snacks.util.lsp.on({ name = "vtsls" }, function(buffer, client)
      client.commands["_typescript.moveToFileRefactoring"] = function(command)
        local action, uri, range = unpack(command.arguments)

        local function move(newf)
          client:request("workspace/executeCommand", {
            command = command.command,
            arguments = { action, uri, range, newf },
          })
        end

        local fname = vim.uri_to_fname(uri)
        client:request("workspace/executeCommand", {
          command = "typescript.tsserverRequest",
          arguments = {
            "getMoveToRefactoringFileSuggestions",
            {
              file = fname,
              startLine = range.start.line + 1,
              startOffset = range.start.character + 1,
              endLine = range["end"].line + 1,
              endOffset = range["end"].character + 1,
            },
          },
        }, function(_, result)
          local files = result.body.files
          table.insert(files, 1, "Enter new path...")
          vim.ui.select(files, {
            prompt = "Select move destination:",
            format_item = function(f)
              return vim.fn.fnamemodify(f, ":~:.")
            end,
          }, function(f)
            if f and f:find("^Enter new path") then
              vim.ui.input({
                prompt = "Enter move destination:",
                default = vim.fn.fnamemodify(fname, ":h") .. "/",
                completion = "file",
              }, function(newf)
                return newf and move(newf)
              end)
            elseif f then
              move(f)
            end
          end)
        end)
      end
    end)

    local group = vim.api.nvim_create_augroup("nix_vtsls_keys", { clear = true })
    vim.api.nvim_create_autocmd("LspAttach", {
      group = group,
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client or client.name ~= "vtsls" then
          return
        end
        local opts = { buffer = ev.buf }

        vim.keymap.set("n", "gD", function()
          local win = vim.api.nvim_get_current_win()
          local params = vim.lsp.util.make_position_params(win, "utf-16")
          Nix.lsp.execute({
            command = "typescript.goToSourceDefinition",
            arguments = { params.textDocument.uri, params.position },
            open = true,
          })
        end, vim.tbl_extend("force", opts, { desc = "Goto Source Definition" }))

        vim.keymap.set("n", "gR", function()
          Nix.lsp.execute({
            command = "typescript.findAllFileReferences",
            arguments = { vim.uri_from_bufnr(0) },
            open = true,
          })
        end, vim.tbl_extend("force", opts, { desc = "File References" }))

        vim.keymap.set("n", "<leader>co", Nix.lsp.action["source.organizeImports"], vim.tbl_extend("force", opts, {
          desc = "Organize Imports",
        }))
        vim.keymap.set("n", "<leader>cM", Nix.lsp.action["source.addMissingImports.ts"], vim.tbl_extend("force", opts, {
          desc = "Add missing imports",
        }))
        vim.keymap.set("n", "<leader>cu", Nix.lsp.action["source.removeUnused.ts"], vim.tbl_extend("force", opts, {
          desc = "Remove unused imports",
        }))
        vim.keymap.set("n", "<leader>cD", Nix.lsp.action["source.fixAll.ts"], vim.tbl_extend("force", opts, {
          desc = "Fix all diagnostics",
        }))
        vim.keymap.set("n", "<leader>cV", function()
          Nix.lsp.execute({ command = "typescript.selectTypeScriptVersion" })
        end, vim.tbl_extend("force", opts, { desc = "Select TS workspace version" }))
      end,
    })

    local dap = require("dap")
    for _, adapter_type in ipairs({ "node", "chrome", "msedge" }) do
      local pwa_type = "pwa-" .. adapter_type
      if not dap.adapters[pwa_type] then
        dap.adapters[pwa_type] = {
          type = "server",
          host = "localhost",
          port = "''${port}",
          executable = {
            command = "js-debug-adapter",
            args = { "''${port}" },
          },
        }
      end

      if not dap.adapters[adapter_type] then
        dap.adapters[adapter_type] = function(cb, config)
          local native = dap.adapters[pwa_type]
          config.type = pwa_type
          if type(native) == "function" then
            native(cb, config)
          else
            cb(native)
          end
        end
      end
    end

    local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
    local vscode = require("dap.ext.vscode")
    vscode.type_to_filetypes["node"] = js_filetypes
    vscode.type_to_filetypes["pwa-node"] = js_filetypes

    for _, language in ipairs(js_filetypes) do
      if not dap.configurations[language] then
        local runtime = nil
        if language:find("typescript") then
          runtime = vim.fn.executable("tsx") == 1 and "tsx" or "ts-node"
        end
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "''${file}",
            cwd = "''${workspaceFolder}",
            sourceMaps = true,
            runtimeExecutable = runtime,
            skipFiles = { "<node_internals>/**", "node_modules/**" },
            resolveSourceMapLocations = {
              "''${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "''${workspaceFolder}",
            sourceMaps = true,
            runtimeExecutable = runtime,
            skipFiles = { "<node_internals>/**", "node_modules/**" },
            resolveSourceMapLocations = {
              "''${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
        }
      end
    end
  '';
}
