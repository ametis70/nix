{ lib, pkgs, ... }:
{
  plugins.treesitter.settings.ensure_installed = lib.mkAfter [ "ninja" "rst" ];

  plugins.lsp.servers.pyright.enable = true;

  plugins.lsp.servers.ruff = {
    enable = true;
    extraOptions = {
      cmd_env = { RUFF_TRACE = "messages"; };
      init_options = {
        settings = {
          logLevel = "error";
        };
      };
    };
  };

  plugins.neotest.adapters.python.enable = true;

  plugins.dap-python = {
    enable = true;
    adapterPythonPath = "debugpy-adapter";
  };

  plugins.venv-selector = {
    enable = true;
    settings = {
      options = {
        notify_user_on_venv_activation = true;
      };
    };
  };

  keymaps = [
    {
      key = "<leader>cv";
      mode = [ "n" ];
      action = "<cmd>VenvSelect<cr>";
      options.desc = "Select VirtualEnv";
    }
    {
      key = "<leader>dPt";
      mode = [ "n" ];
      action.__raw = "function() require('dap-python').test_method() end";
      options.desc = "Debug Method";
    }
    {
      key = "<leader>dPc";
      mode = [ "n" ];
      action.__raw = "function() require('dap-python').test_class() end";
      options.desc = "Debug Class";
    }
  ];

  extraPackages = with pkgs; [
    ruff
  ];

  extraConfigLua = ''
    Snacks.util.lsp.on({ name = "ruff" }, function(_, client)
      client.server_capabilities.hoverProvider = false
    end)

    local group = vim.api.nvim_create_augroup("nix_python_keys", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "python",
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
