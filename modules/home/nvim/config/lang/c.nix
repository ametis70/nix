{ lib, ... }:
{
  plugins.treesitter.settings.ensure_installed = lib.mkAfter [ "cpp" ];

  plugins.clangd-extensions = {
    enable = true;
    enableOffsetEncodingWorkaround = true;
    settings = {
      inlay_hints = {
        inline = false;
      };
      ast = {
        role_icons = {
          type = "";
          declaration = "";
          expression = "";
          specifier = "";
          statement = "";
          "template argument" = "";
        };
        kind_icons = {
          Compound = "";
          Recovery = "";
          TranslationUnit = "";
          PackExpansion = "";
          TemplateTypeParm = "";
          TemplateTemplateParm = "";
          TemplateParamObject = "";
        };
      };
    };
  };

  plugins.lsp.servers.clangd = {
    enable = true;
    rootMarkers = [
      "compile_commands.json"
      "compile_flags.txt"
      "configure.ac"
      "Makefile"
      "configure.in"
      "config.h.in"
      "meson.build"
      "meson_options.txt"
      "build.ninja"
      ".git"
    ];
    cmd = [
      "clangd"
      "--background-index"
      "--clang-tidy"
      "--header-insertion=iwyu"
      "--completion-style=detailed"
      "--function-arg-placeholders"
      "--fallback-style=llvm"
    ];
    extraOptions = {
      capabilities = {
        offsetEncoding = [ "utf-16" ];
      };
      init_options = {
        usePlaceholders = true;
        completeUnimported = true;
        clangdFileStatus = true;
      };
    };
  };

  keymaps = [
    {
      key = "<leader>ch";
      mode = [ "n" ];
      action = "<cmd>LspClangdSwitchSourceHeader<cr>";
      options.desc = "Switch Source/Header (C/C++)";
    }
  ];

  extraConfigLua = ''
    local dap = require("dap")
    if not dap.adapters["codelldb"] then
      dap.adapters["codelldb"] = {
        type = "server",
        host = "localhost",
        port = "''${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "''${port}" },
        },
      }
    end

    for _, lang in ipairs({ "c", "cpp" }) do
      dap.configurations[lang] = {
        {
          type = "codelldb",
          request = "launch",
          name = "Launch file",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "''${workspaceFolder}",
        },
        {
          type = "codelldb",
          request = "attach",
          name = "Attach to process",
          pid = require("dap.utils").pick_process,
          cwd = "''${workspaceFolder}",
        },
      }
    end
  '';
}
