{
  plugins.snacks = {
    enable = true;
    settings = {
      indent = { enabled = true; };
      input = { enabled = true; };
      notifier = { enabled = true; };
      scope = { enabled = true; };
      scroll = { enabled = true; };
      statuscolumn = { enabled = false; };
      toggle = { map.__raw = "vim.keymap.set"; };
      words = { enabled = true; };
      bigfile = { enabled = true; };
      quickfile = { enabled = true; };
      terminal = {
        win = {
          keys = {
            nav_h = {
              __unkeyed-1 = "<C-h>";
              __unkeyed-2.__raw = "function(self) return self:is_floating() and '<c-h>' or vim.schedule(function() vim.cmd.wincmd('h') end) end";
              desc = "Go to Left Window";
              expr = true;
              mode = "t";
            };
            nav_j = {
              __unkeyed-1 = "<C-j>";
              __unkeyed-2.__raw = "function(self) return self:is_floating() and '<c-j>' or vim.schedule(function() vim.cmd.wincmd('j') end) end";
              desc = "Go to Lower Window";
              expr = true;
              mode = "t";
            };
            nav_k = {
              __unkeyed-1 = "<C-k>";
              __unkeyed-2.__raw = "function(self) return self:is_floating() and '<c-k>' or vim.schedule(function() vim.cmd.wincmd('k') end) end";
              desc = "Go to Upper Window";
              expr = true;
              mode = "t";
            };
            nav_l = {
              __unkeyed-1 = "<C-l>";
              __unkeyed-2.__raw = "function(self) return self:is_floating() and '<c-l>' or vim.schedule(function() vim.cmd.wincmd('l') end) end";
              desc = "Go to Right Window";
              expr = true;
              mode = "t";
            };
          };
        };
      };
      dashboard = {
        preset = {
          pick.__raw = ''
            function(cmd, opts)
              return Nix.pick.make(cmd, opts)()
            end
          '';
          header = " █████  ███    ███ ███████ ████████ ██ ███████ ███████  ██████  \n"
            + "██   ██ ████  ████ ██         ██    ██ ██           ██ ██  ████ \n"
            + "███████ ██ ████ ██ █████      ██    ██ ███████     ██  ██ ██ ██ \n"
            + "██   ██ ██  ██  ██ ██         ██    ██      ██    ██   ████  ██ \n"
            + "██   ██ ██      ██ ███████    ██    ██ ███████    ██    ██████  \n"
            + "                                                                \n"
            + "                                                                \n";
          keys = [
            { icon = " "; key = "f"; desc = "Find File"; action = ":lua Snacks.dashboard.pick('files')"; }
            { icon = " "; key = "n"; desc = "New File"; action = ":ene | startinsert"; }
            { icon = " "; key = "p"; desc = "Projects"; action = ":lua Snacks.picker.projects()"; }
            { icon = " "; key = "g"; desc = "Find Text"; action = ":lua Snacks.dashboard.pick('live_grep')"; }
            { icon = " "; key = "r"; desc = "Recent Files"; action = ":lua Snacks.dashboard.pick('oldfiles')"; }
            { icon = " "; key = "c"; desc = "Config"; action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})"; }
            { icon = " "; key = "s"; desc = "Restore Session"; section = "session"; }
            { icon = " "; key = "q"; desc = "Quit"; action = ":qa"; }
          ];
        };
        sections = [
          { section = "header"; }
          { section = "keys"; gap = 1; padding = 1; }
        ];
      };
      picker = {
        win = {
          input = {
            keys = {
              "<a-a>" = { __unkeyed-1 = "sidekick_send"; mode = [ "n" "i" ]; };
              "<a-c>" = { __unkeyed-1 = "toggle_cwd"; mode = [ "n" "i" ]; };
              "<a-s>" = { __unkeyed-1 = "flash"; mode = [ "n" "i" ]; };
              "s" = { __unkeyed-1 = "flash"; };
              "<a-t>" = { __unkeyed-1 = "trouble_open"; mode = [ "n" "i" ]; };
            };
          };
        };
        actions = {
          toggle_cwd.__raw = ''
            function(p)
              local root = Nix.root.get({ buf = p.input.filter.current_buf, normalize = true })
              local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
              local current = p:cwd()
              p:set_cwd(current == root and cwd or root)
              p:find()
            end
          '';
          flash.__raw = ''
            function(picker)
              require("flash").jump({
                pattern = "^",
                label = { after = { 0, 0 } },
                search = {
                  mode = "search",
                  exclude = {
                    function(win)
                      return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                    end,
                  },
                },
                action = function(match)
                  local idx = picker.list:row2idx(match.pos[1])
                  picker.list:_move(idx, true, true)
                end,
              })
            end
          '';
          trouble_open.__raw = ''
            function(...)
              return require("trouble.sources.snacks").actions.trouble_open.action(...)
            end
          '';
        };
      };
    };
  };

  keymaps = [
    { key = "<leader>."; mode = [ "n" ]; action = "<cmd>lua Snacks.scratch()<cr>"; options.desc = "Toggle Scratch Buffer"; }
    { key = "<leader>S"; mode = [ "n" ]; action = "<cmd>lua Snacks.scratch.select()<cr>"; options.desc = "Select Scratch Buffer"; }
    { key = "<leader>dps"; mode = [ "n" ]; action = "<cmd>lua Snacks.profiler.scratch()<cr>"; options.desc = "Profiler Scratch Buffer"; }

    { key = "<leader>n"; mode = [ "n" ]; action.__raw = ''
        function()
          if Snacks.config.picker and Snacks.config.picker.enabled then
            Snacks.picker.notifications()
          else
            Snacks.notifier.show_history()
          end
        end
      ''; options.desc = "Notification History"; }
    { key = "<leader>un"; mode = [ "n" ]; action = "<cmd>lua Snacks.notifier.hide()<cr>"; options.desc = "Dismiss All Notifications"; }

    { key = "<leader>,"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.buffers()<cr>"; options.desc = "Buffers"; }
    { key = "<leader>/"; mode = [ "n" ]; action.__raw = "function() Nix.pick.grep({}) end"; options.desc = "Grep (Root Dir)"; }
    { key = "<leader>:"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.command_history()<cr>"; options.desc = "Command History"; }
    { key = "<leader><space>"; mode = [ "n" ]; action.__raw = "function() Nix.pick.files({}) end"; options.desc = "Find Files (Root Dir)"; }

    { key = "<leader>fb"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.buffers()<cr>"; options.desc = "Buffers"; }
    { key = "<leader>fB"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.buffers({ hidden = true, nofile = true })<cr>"; options.desc = "Buffers (all)"; }
    { key = "<leader>fc"; mode = [ "n" ]; action.__raw = "Nix.pick.config_files()"; options.desc = "Find Config File"; }
    { key = "<leader>ff"; mode = [ "n" ]; action.__raw = "function() Nix.pick.files({}) end"; options.desc = "Find Files (Root Dir)"; }
    { key = "<leader>fF"; mode = [ "n" ]; action.__raw = "function() Nix.pick.files({ root = false }) end"; options.desc = "Find Files (cwd)"; }
    { key = "<leader>fg"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.git_files()<cr>"; options.desc = "Find Files (git-files)"; }
    { key = "<leader>fr"; mode = [ "n" ]; action.__raw = "function() Nix.pick.oldfiles({}) end"; options.desc = "Recent"; }
    { key = "<leader>fR"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.recent({ filter = { cwd = true }})<cr>"; options.desc = "Recent (cwd)"; }
    { key = "<leader>fp"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.projects()<cr>"; options.desc = "Projects"; }

    { key = "<leader>gd"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.git_diff()<cr>"; options.desc = "Git Diff (hunks)"; }
    { key = "<leader>gD"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.git_diff({ base = 'origin', group = true })<cr>"; options.desc = "Git Diff (origin)"; }
    { key = "<leader>gs"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.git_status()<cr>"; options.desc = "Git Status"; }
    { key = "<leader>gS"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.git_stash()<cr>"; options.desc = "Git Stash"; }
    { key = "<leader>gi"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.gh_issue()<cr>"; options.desc = "GitHub Issues (open)"; }
    { key = "<leader>gI"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.gh_issue({ state = 'all' })<cr>"; options.desc = "GitHub Issues (all)"; }
    { key = "<leader>gp"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.gh_pr()<cr>"; options.desc = "GitHub Pull Requests (open)"; }
    { key = "<leader>gP"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.gh_pr({ state = 'all' })<cr>"; options.desc = "GitHub Pull Requests (all)"; }

    { key = "<leader>sb"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.lines()<cr>"; options.desc = "Buffer Lines"; }
    { key = "<leader>sB"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.grep_buffers()<cr>"; options.desc = "Grep Open Buffers"; }
    { key = "<leader>sg"; mode = [ "n" ]; action.__raw = "function() Nix.pick.grep({}) end"; options.desc = "Grep (Root Dir)"; }
    { key = "<leader>sG"; mode = [ "n" ]; action.__raw = "function() Nix.pick.grep({ root = false }) end"; options.desc = "Grep (cwd)"; }
    { key = "<leader>sp"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.lazy()<cr>"; options.desc = "Search for Plugin Spec"; }
    { key = "<leader>sw"; mode = [ "n" "x" ]; action.__raw = "function() Nix.pick.grep_word({}) end"; options.desc = "Visual selection or word (Root Dir)"; }
    { key = "<leader>sW"; mode = [ "n" "x" ]; action.__raw = "function() Nix.pick.grep_word({ root = false }) end"; options.desc = "Visual selection or word (cwd)"; }

    { key = "<leader>s\""; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.registers()<cr>"; options.desc = "Registers"; }
    { key = "<leader>s/"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.search_history()<cr>"; options.desc = "Search History"; }
    { key = "<leader>sa"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.autocmds()<cr>"; options.desc = "Autocmds"; }
    { key = "<leader>sc"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.command_history()<cr>"; options.desc = "Command History"; }
    { key = "<leader>sC"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.commands()<cr>"; options.desc = "Commands"; }
    { key = "<leader>sd"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.diagnostics()<cr>"; options.desc = "Diagnostics"; }
    { key = "<leader>sD"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.diagnostics_buffer()<cr>"; options.desc = "Buffer Diagnostics"; }
    { key = "<leader>sh"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.help()<cr>"; options.desc = "Help Pages"; }
    { key = "<leader>sH"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.highlights()<cr>"; options.desc = "Highlights"; }
    { key = "<leader>si"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.icons()<cr>"; options.desc = "Icons"; }
    { key = "<leader>sj"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.jumps()<cr>"; options.desc = "Jumps"; }
    { key = "<leader>sk"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.keymaps()<cr>"; options.desc = "Keymaps"; }
    { key = "<leader>sl"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.loclist()<cr>"; options.desc = "Location List"; }
    { key = "<leader>sM"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.man()<cr>"; options.desc = "Man Pages"; }
    { key = "<leader>sm"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.marks()<cr>"; options.desc = "Marks"; }
    { key = "<leader>sR"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.resume()<cr>"; options.desc = "Resume"; }
    { key = "<leader>sq"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.qflist()<cr>"; options.desc = "Quickfix List"; }
    { key = "<leader>su"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.undo()<cr>"; options.desc = "Undotree"; }

    { key = "<leader>uC"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.colorschemes()<cr>"; options.desc = "Colorschemes"; }

    { key = "<leader>e"; mode = [ "n" ]; action = "<cmd>lua Snacks.explorer()<cr>"; options.desc = "Explorer"; }

    { key = "<leader>gL"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.git_log()<cr>"; options.desc = "Git Log (cwd)"; }
    { key = "<leader>gb"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.git_log_line()<cr>"; options.desc = "Git Blame Line"; }
    { key = "<leader>gf"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.git_log_file()<cr>"; options.desc = "Git Current File History"; }
    { key = "<leader>gl"; mode = [ "n" ]; action = "<cmd>lua Snacks.picker.git_log({ cwd = Nix.root.git() })<cr>"; options.desc = "Git Log"; }
    { key = "<leader>gB"; mode = [ "n" "x" ]; action = "<cmd>lua Snacks.gitbrowse()<cr>"; options.desc = "Git Browse (open)"; }
    { key = "<leader>gY"; mode = [ "n" "x" ]; action = "<cmd>lua Snacks.gitbrowse({ open = function(url) vim.fn.setreg('+', url) end, notify = false })<cr>"; options.desc = "Git Browse (copy)"; }
  ];

  extraConfigLua = ''
    -- Snacks toggles
    Nix.format.snacks_toggle():map("<leader>uf")
    Nix.format.snacks_toggle(true):map("<leader>uF")
    Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
    Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
    Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
    Snacks.toggle.diagnostics():map("<leader>ud")
    Snacks.toggle.line_number():map("<leader>ul")
    Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>uc")
    Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>uA")
    Snacks.toggle.treesitter():map("<leader>uT")
    Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
    Snacks.toggle.dim():map("<leader>uD")
    Snacks.toggle.animate():map("<leader>ua")
    Snacks.toggle.indent():map("<leader>ug")
    Snacks.toggle.scroll():map("<leader>uS")
    Snacks.toggle.profiler():map("<leader>dpp")
    Snacks.toggle.profiler_highlights():map("<leader>dph")

    if vim.lsp.inlay_hint then
      Snacks.toggle.inlay_hints():map("<leader>uh")
    end

    if vim.fn.executable("lazygit") == 1 then
      vim.keymap.set("n", "<leader>gg", function()
        Snacks.lazygit({ cwd = Nix.root.git() })
      end, { desc = "Lazygit (Root Dir)" })
      vim.keymap.set("n", "<leader>gG", function()
        Snacks.lazygit()
      end, { desc = "Lazygit (cwd)" })
    end

    Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
    Snacks.toggle.zen():map("<leader>uz")
  '';
}
