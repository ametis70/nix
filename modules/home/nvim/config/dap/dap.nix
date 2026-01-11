{ pkgs, ... }:
{
  plugins.dap = {
    enable = true;
    signs = {
      dapBreakpoint = { text = " "; };
      dapBreakpointCondition = { text = " "; };
      dapBreakpointRejected = { text = " "; };
      dapLogPoint = { text = ".>"; };
      dapStopped = { text = "󰁕 "; };
    };
  };

  plugins.dap-ui = {
    enable = true;
    settings = { };
  };

  plugins.dap-virtual-text = {
    enable = true;
    settings = { };
  };

  extraPlugins = with pkgs.vimPlugins; [
    nvim-nio
    one-small-step-for-vimkind
  ];

  keymaps = [
    { key = "<leader>dB"; mode = [ "n" ]; action = "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>"; options.desc = "Breakpoint Condition"; }
    { key = "<leader>db"; mode = [ "n" ]; action = "<cmd>lua require('dap').toggle_breakpoint()<cr>"; options.desc = "Toggle Breakpoint"; }
    { key = "<leader>dc"; mode = [ "n" ]; action = "<cmd>lua require('dap').continue()<cr>"; options.desc = "Run/Continue"; }
    { key = "<leader>da"; mode = [ "n" ]; action.__raw = ''
        function()
          local dap = require("dap")
          dap.continue({ before = function(config)
            local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
            local args_str = type(args) == "table" and table.concat(args, " ") or args
            config = vim.deepcopy(config)
            config.args = function()
              local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str))
              if config.type and config.type == "java" then
                return new_args
              end
              return require("dap.utils").splitstr(new_args)
            end
            return config
          end })
        end
      ''; options.desc = "Run with Args"; }
    { key = "<leader>dC"; mode = [ "n" ]; action = "<cmd>lua require('dap').run_to_cursor()<cr>"; options.desc = "Run to Cursor"; }
    { key = "<leader>dg"; mode = [ "n" ]; action = "<cmd>lua require('dap').goto_()<cr>"; options.desc = "Go to Line (No Execute)"; }
    { key = "<leader>di"; mode = [ "n" ]; action = "<cmd>lua require('dap').step_into()<cr>"; options.desc = "Step Into"; }
    { key = "<leader>dj"; mode = [ "n" ]; action = "<cmd>lua require('dap').down()<cr>"; options.desc = "Down"; }
    { key = "<leader>dk"; mode = [ "n" ]; action = "<cmd>lua require('dap').up()<cr>"; options.desc = "Up"; }
    { key = "<leader>dl"; mode = [ "n" ]; action = "<cmd>lua require('dap').run_last()<cr>"; options.desc = "Run Last"; }
    { key = "<leader>do"; mode = [ "n" ]; action = "<cmd>lua require('dap').step_out()<cr>"; options.desc = "Step Out"; }
    { key = "<leader>dO"; mode = [ "n" ]; action = "<cmd>lua require('dap').step_over()<cr>"; options.desc = "Step Over"; }
    { key = "<leader>dP"; mode = [ "n" ]; action = "<cmd>lua require('dap').pause()<cr>"; options.desc = "Pause"; }
    { key = "<leader>dr"; mode = [ "n" ]; action = "<cmd>lua require('dap').repl.toggle()<cr>"; options.desc = "Toggle REPL"; }
    { key = "<leader>ds"; mode = [ "n" ]; action = "<cmd>lua require('dap').session()<cr>"; options.desc = "Session"; }
    { key = "<leader>dt"; mode = [ "n" ]; action = "<cmd>lua require('dap').terminate()<cr>"; options.desc = "Terminate"; }
    { key = "<leader>dw"; mode = [ "n" ]; action = "<cmd>lua require('dap.ui.widgets').hover()<cr>"; options.desc = "Widgets"; }

    { key = "<leader>du"; mode = [ "n" ]; action = "<cmd>lua require('dapui').toggle({})<cr>"; options.desc = "Dap UI"; }
    { key = "<leader>de"; mode = [ "n" "x" ]; action = "<cmd>lua require('dapui').eval()<cr>"; options.desc = "Eval"; }
  ];

  extraConfigLua = ''
    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

    local dap, dapui = require("dap"), require("dapui")
    dapui.setup({})

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open({})
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close({})
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close({})
    end

    local vscode = require("dap.ext.vscode")
    local json = require("plenary.json")
    vscode.json_decode = function(str)
      return vim.json.decode(json.json_strip_comments(str))
    end

    dap.adapters.nlua = function(callback, conf)
      local adapter = {
        type = "server",
        host = conf.host or "127.0.0.1",
        port = conf.port or 8086,
      }
      if conf.start_neovim then
        local dap_run = dap.run
        dap.run = function(c)
          adapter.port = c.port
          adapter.host = c.host
        end
        require("osv").run_this()
        dap.run = dap_run
      end
      callback(adapter)
    end
    dap.configurations.lua = {
      {
        type = "nlua",
        request = "attach",
        name = "Run this file",
        start_neovim = {},
      },
      {
        type = "nlua",
        request = "attach",
        name = "Attach to running Neovim instance (port = 8086)",
        port = 8086,
      },
    }
  '';
}
