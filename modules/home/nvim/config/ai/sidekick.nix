{
  plugins.sidekick = {
    enable = true;
    settings = {
      cli = {
        tools = {
          codex = {
            cmd = [
              "codex"
              "--enable"
              "web_search_request"
            ];
          };
          copilot = {
            cmd = [
              "copilot"
              "--banner"
            ];
          };
          opencode = {
            cmd = [ "opencode" ];
            env = {
              OPENCODE_THEME = "system";
            };
          };
        };
      };
    };
  };

  plugins.lsp.servers.copilot.enable = true;

  plugins.snacks.settings.picker = {
    actions = {
      sidekick_send.__raw = ''
        function(...)
          return require("sidekick.cli.picker.snacks").send(...)
        end
      '';
    };
  };

  keymaps = [
    {
      key = "<tab>";
      mode = [ "n" ];
      action.__raw = "Nix.cmp.map({ 'ai_nes' }, '<tab>')";
      options = {
        expr = true;
        desc = "Next edit";
      };
    }
    {
      key = "<leader>a";
      mode = [
        "n"
        "v"
      ];
      action = "";
      options.desc = "+ai";
    }
    {
      key = "<c-.>";
      mode = [
        "n"
        "t"
        "i"
        "x"
      ];
      action = "<cmd>lua Nix.sidekick.toggle_default()<cr>";
      options.desc = "Sidekick Toggle";
    }
    {
      key = "<leader>aa";
      mode = [ "n" ];
      action = "<cmd>lua Nix.sidekick.toggle_default()<cr>";
      options.desc = "Sidekick Toggle CLI";
    }
    {
      key = "<leader>as";
      mode = [ "n" ];
      action = "<cmd>lua require('sidekick.cli').select()<cr>";
      options.desc = "Select CLI";
    }
    {
      key = "<leader>ad";
      mode = [ "n" ];
      action = "<cmd>lua require('sidekick.cli').close()<cr>";
      options.desc = "Detach a CLI Session";
    }
    {
      key = "<leader>at";
      mode = [
        "n"
        "x"
      ];
      action = "<cmd>lua require('sidekick.cli').send({ msg = '{this}' })<cr>";
      options.desc = "Send This";
    }
    {
      key = "<leader>af";
      mode = [ "n" ];
      action = "<cmd>lua require('sidekick.cli').send({ msg = '{file}' })<cr>";
      options.desc = "Send File";
    }
    {
      key = "<leader>av";
      mode = [ "x" ];
      action = "<cmd>lua require('sidekick.cli').send({ msg = '{selection}' })<cr>";
      options.desc = "Send Visual Selection";
    }
    {
      key = "<leader>ap";
      mode = [
        "n"
        "x"
      ];
      action = "<cmd>lua require('sidekick.cli').prompt()<cr>";
      options.desc = "Sidekick Select Prompt";
    }
  ];

  extraConfigLua = ''
    Nix.sidekick = Nix.sidekick or {}
    Nix.sidekick.toggle_default = function()
      local State = require("sidekick.cli.state")
      if #State.get({ attached = true }) == 0 then
        require("sidekick.cli").toggle({ name = "opencode" })
        return
      end
      require("sidekick.cli").toggle()
    end

    Nix.cmp.actions.ai_nes = function()
      local Nes = require("sidekick.nes")
      if Nes.have() and (Nes.jump() or Nes.apply()) then
        return true
      end
    end

    Snacks.toggle({
      name = "Sidekick NES",
      get = function()
        return require("sidekick.nes").enabled
      end,
      set = function(state)
        require("sidekick.nes").enable(state)
      end,
    }):map("<leader>uN")

    local ok, lualine = pcall(require, "lualine")
    if ok then
      local cfg = lualine.get_config()
      local icons = {
        Error = { " ", "DiagnosticError" },
        Inactive = { " ", "MsgArea" },
        Warning = { " ", "DiagnosticWarn" },
        Normal = { Nix.icons.kinds.Copilot, "Special" },
      }
      table.insert(cfg.sections.lualine_x, 2, {
        function()
          local status = require("sidekick.status").get()
          return status and vim.tbl_get(icons, status.kind, 1)
        end,
        cond = function()
          return require("sidekick.status").get() ~= nil
        end,
        color = function()
          local status = require("sidekick.status").get()
          local hl = status and (status.busy and "DiagnosticWarn" or vim.tbl_get(icons, status.kind, 2))
          return { fg = Snacks.util.color(hl) }
        end,
      })

      table.insert(cfg.sections.lualine_x, 2, {
        function()
          local status = require("sidekick.status").cli()
          return " " .. (#status > 1 and #status or "")
        end,
        cond = function()
          return #require("sidekick.status").cli() > 0
        end,
        color = function()
          return { fg = Snacks.util.color("Special") }
        end,
      })

      lualine.setup(cfg)
    end
  '';
}
