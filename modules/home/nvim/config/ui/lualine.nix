{
  plugins.lualine = {
    enable = true;
    settings = {
      options = {
        theme = "auto";
        globalstatus.__raw = "vim.o.laststatus == 3";
        disabledFiletypes = {
          statusline = [ "dashboard" "alpha" "ministarter" "snacks_dashboard" ];
        };
      };
      sections = {
        lualine_a = [ "mode" ];
        lualine_b = [ "branch" ];
        lualine_c = [
          {
            __raw = "Nix.lualine.root_dir()";
          }
          {
            __unkeyed-1 = "diagnostics";
            symbols = {
              error.__raw = "Nix.icons.diagnostics.Error";
              warn.__raw = "Nix.icons.diagnostics.Warn";
              info.__raw = "Nix.icons.diagnostics.Info";
              hint.__raw = "Nix.icons.diagnostics.Hint";
            };
          }
          {
            __unkeyed-1 = "filetype";
            icon_only = true;
            separator = "";
            padding = { left = 1; right = 0; };
          }
          {
            __raw = "Nix.lualine.pretty_path()";
          }
        ];
        lualine_x = [
          {
            __raw = "Snacks.profiler.status()";
          }
          {
            __unkeyed-1.__raw = "function() return require('noice').api.status.command.get() end";
            cond.__raw = "function() return package.loaded['noice'] and require('noice').api.status.command.has() end";
            color.__raw = "function() return { fg = Snacks.util.color('Statement') } end";
          }
          {
            __unkeyed-1.__raw = "function() return require('noice').api.status.mode.get() end";
            cond.__raw = "function() return package.loaded['noice'] and require('noice').api.status.mode.has() end";
            color.__raw = "function() return { fg = Snacks.util.color('Constant') } end";
          }
          {
            __unkeyed-1.__raw = "function() return '  ' .. require('dap').status() end";
            cond.__raw = "function() return package.loaded['dap'] and require('dap').status() ~= '' end";
            color.__raw = "function() return { fg = Snacks.util.color('Debug') } end";
          }
          {
            __unkeyed-1.__raw = ''
              function()
                local ok, lazy_status = pcall(require, "lazy.status")
                return ok and lazy_status.updates() or ""
              end
            '';
            cond.__raw = ''
              function()
                local ok, lazy_status = pcall(require, "lazy.status")
                return ok and lazy_status.has_updates()
              end
            '';
            color.__raw = "function() return { fg = Snacks.util.color('Special') } end";
          }
          {
            __unkeyed-1 = "diff";
            symbols = {
              added.__raw = "Nix.icons.git.added";
              modified.__raw = "Nix.icons.git.modified";
              removed.__raw = "Nix.icons.git.removed";
            };
            source.__raw = ''
              function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end
            '';
          }
        ];
        lualine_y = [
          { __unkeyed-1 = "progress"; separator = " "; padding = { left = 1; right = 0; }; }
          { __unkeyed-1 = "location"; padding = { left = 0; right = 1; }; }
        ];
        lualine_z = [
          {
            __unkeyed-1.__raw = "function() return ' ' .. os.date('%R') end";
          }
        ];
      };
      extensions = [ "neo-tree" "lazy" "fzf" ];
    };
  };

  extraConfigLua = ''
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.laststatus = 0
    end

    local ok, lualine = pcall(require, "lualine")
    if not ok then
      return
    end

    local cfg = lualine.get_config()

    if vim.g.trouble_lualine and pcall(require, "trouble") then
      local trouble = require("trouble")
      local symbols = trouble.statusline({
        mode = "symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = "{kind_icon}{symbol.name:Normal}",
        hl_group = "lualine_c_normal",
      })
      table.insert(cfg.sections.lualine_c, {
        symbols and symbols.get,
        cond = function()
          return vim.b.trouble_lualine ~= false and symbols.has()
        end,
      })
    end

    -- mini.diff integration when present
    for _, comp in ipairs(cfg.sections.lualine_x or {}) do
      if comp[1] == "diff" then
        comp.source = function()
          local summary = vim.b.minidiff_summary
          return summary and {
            added = summary.add,
            modified = summary.change,
            removed = summary.delete,
          }
        end
        break
      end
    end

    lualine.setup(cfg)
  '';
}
