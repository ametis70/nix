{
  keymaps = [
    {
      key = "j";
      mode = [ "n" "x" ];
      action = "v:count == 0 ? 'gj' : 'j'";
      options = {
        expr = true;
        silent = true;
        desc = "Down";
      };
    }
    {
      key = "<Down>";
      mode = [ "n" "x" ];
      action = "v:count == 0 ? 'gj' : 'j'";
      options = {
        expr = true;
        silent = true;
        desc = "Down";
      };
    }
    {
      key = "k";
      mode = [ "n" "x" ];
      action = "v:count == 0 ? 'gk' : 'k'";
      options = {
        expr = true;
        silent = true;
        desc = "Up";
      };
    }
    {
      key = "<Up>";
      mode = [ "n" "x" ];
      action = "v:count == 0 ? 'gk' : 'k'";
      options = {
        expr = true;
        silent = true;
        desc = "Up";
      };
    }

    {
      key = "<C-h>";
      mode = [ "n" ];
      action = "<C-w>h";
      options = {
        remap = true;
        desc = "Go to Left Window";
      };
    }
    {
      key = "<C-j>";
      mode = [ "n" ];
      action = "<C-w>j";
      options = {
        remap = true;
        desc = "Go to Lower Window";
      };
    }
    {
      key = "<C-k>";
      mode = [ "n" ];
      action = "<C-w>k";
      options = {
        remap = true;
        desc = "Go to Upper Window";
      };
    }
    {
      key = "<C-l>";
      mode = [ "n" ];
      action = "<C-w>l";
      options = {
        remap = true;
        desc = "Go to Right Window";
      };
    }

    {
      key = "<C-Up>";
      mode = [ "n" ];
      action = "<cmd>resize +2<cr>";
      options.desc = "Increase Window Height";
    }
    {
      key = "<C-Down>";
      mode = [ "n" ];
      action = "<cmd>resize -2<cr>";
      options.desc = "Decrease Window Height";
    }
    {
      key = "<C-Left>";
      mode = [ "n" ];
      action = "<cmd>vertical resize -2<cr>";
      options.desc = "Decrease Window Width";
    }
    {
      key = "<C-Right>";
      mode = [ "n" ];
      action = "<cmd>vertical resize +2<cr>";
      options.desc = "Increase Window Width";
    }

    {
      key = "<A-j>";
      mode = [ "n" ];
      action = "<cmd>execute 'move .+' . v:count1<cr>==";
      options.desc = "Move Down";
    }
    {
      key = "<A-k>";
      mode = [ "n" ];
      action = "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==";
      options.desc = "Move Up";
    }
    {
      key = "<A-j>";
      mode = [ "i" ];
      action = "<esc><cmd>m .+1<cr>==gi";
      options.desc = "Move Down";
    }
    {
      key = "<A-k>";
      mode = [ "i" ];
      action = "<esc><cmd>m .-2<cr>==gi";
      options.desc = "Move Up";
    }
    {
      key = "<A-j>";
      mode = [ "v" ];
      action = ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv";
      options.desc = "Move Down";
    }
    {
      key = "<A-k>";
      mode = [ "v" ];
      action = ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv";
      options.desc = "Move Up";
    }

    {
      key = "<S-h>";
      mode = [ "n" ];
      action = "<cmd>bprevious<cr>";
      options.desc = "Prev Buffer";
    }
    {
      key = "<S-l>";
      mode = [ "n" ];
      action = "<cmd>bnext<cr>";
      options.desc = "Next Buffer";
    }
    {
      key = "[b";
      mode = [ "n" ];
      action = "<cmd>bprevious<cr>";
      options.desc = "Prev Buffer";
    }
    {
      key = "]b";
      mode = [ "n" ];
      action = "<cmd>bnext<cr>";
      options.desc = "Next Buffer";
    }
    {
      key = "<leader>bb";
      mode = [ "n" ];
      action = "<cmd>e #<cr>";
      options.desc = "Switch to Other Buffer";
    }
    {
      key = "<leader>`";
      mode = [ "n" ];
      action = "<cmd>e #<cr>";
      options.desc = "Switch to Other Buffer";
    }
    {
      key = "<leader>bd";
      mode = [ "n" ];
      action.__raw = ''
        function()
          Snacks.bufdelete()
        end
      '';
      options.desc = "Delete Buffer";
    }
    {
      key = "<leader>bo";
      mode = [ "n" ];
      action.__raw = ''
        function()
          Snacks.bufdelete.other()
        end
      '';
      options.desc = "Delete Other Buffers";
    }
    {
      key = "<leader>bD";
      mode = [ "n" ];
      action = "<cmd>:bd<cr>";
      options.desc = "Delete Buffer and Window";
    }

    {
      key = "<esc>";
      mode = [ "i" "n" "s" ];
      action.__raw = ''
        function()
          vim.cmd("noh")
          Nix.cmp.actions.snippet_stop()
          return "<esc>"
        end
      '';
      options = {
        expr = true;
        desc = "Escape and Clear hlsearch";
      };
    }
    {
      key = "<esc>";
      mode = [ "t" ];
      action.__raw = ''
        function()
          if vim.g.term_esc_pending then
            vim.g.term_esc_pending = false
            vim.g.term_esc_seq = (vim.g.term_esc_seq or 0) + 1
            return vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true)
          end

          vim.g.term_esc_pending = true
          local seq = (vim.g.term_esc_seq or 0) + 1
          vim.g.term_esc_seq = seq
          vim.defer_fn(function()
            if vim.g.term_esc_seq == seq then
              vim.g.term_esc_pending = false
            end
          end, 200)

          return vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
        end
      '';
      options = {
        expr = true;
        desc = "Escape or Exit Terminal Mode";
      };
    }

    {
      key = "<leader>ur";
      mode = [ "n" ];
      action = "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>";
      options.desc = "Redraw / Clear hlsearch / Diff Update";
    }

    {
      key = "n";
      mode = [ "n" ];
      action = "'Nn'[v:searchforward].'zv'";
      options = {
        expr = true;
        desc = "Next Search Result";
      };
    }
    {
      key = "n";
      mode = [ "x" "o" ];
      action = "'Nn'[v:searchforward]";
      options = {
        expr = true;
        desc = "Next Search Result";
      };
    }
    {
      key = "N";
      mode = [ "n" ];
      action = "'nN'[v:searchforward].'zv'";
      options = {
        expr = true;
        desc = "Prev Search Result";
      };
    }
    {
      key = "N";
      mode = [ "x" "o" ];
      action = "'nN'[v:searchforward]";
      options = {
        expr = true;
        desc = "Prev Search Result";
      };
    }

    {
      key = ",";
      mode = [ "i" ];
      action = ",<c-g>u";
    }
    {
      key = ".";
      mode = [ "i" ];
      action = ".<c-g>u";
    }
    {
      key = ";";
      mode = [ "i" ];
      action = ";<c-g>u";
    }

    {
      key = "<C-s>";
      mode = [ "i" "x" "n" "s" ];
      action = "<cmd>w<cr><esc>";
      options.desc = "Save File";
    }

    {
      key = "<leader>K";
      mode = [ "n" ];
      action = "<cmd>norm! K<cr>";
      options.desc = "Keywordprg";
    }

    {
      key = "<";
      mode = [ "x" ];
      action = "<gv";
    }
    {
      key = ">";
      mode = [ "x" ];
      action = ">gv";
    }

    {
      key = "gco";
      mode = [ "n" ];
      action = "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>";
      options.desc = "Add Comment Below";
    }
    {
      key = "gcO";
      mode = [ "n" ];
      action = "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>";
      options.desc = "Add Comment Above";
    }

    {
      key = "<leader>fn";
      mode = [ "n" ];
      action = "<cmd>enew<cr>";
      options.desc = "New File";
    }

    {
      key = "<leader>xl";
      mode = [ "n" ];
      action.__raw = ''
        function()
          local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
          if not success and err then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      '';
      options.desc = "Location List";
    }
    {
      key = "<leader>xq";
      mode = [ "n" ];
      action.__raw = ''
        function()
          local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
          if not success and err then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      '';
      options.desc = "Quickfix List";
    }
    {
      key = "[q";
      mode = [ "n" ];
      action = "<cmd>cprev<cr>";
      options.desc = "Previous Quickfix";
    }
    {
      key = "]q";
      mode = [ "n" ];
      action = "<cmd>cnext<cr>";
      options.desc = "Next Quickfix";
    }

    {
      key = "<leader>cf";
      mode = [ "n" "x" ];
      action.__raw = ''
        function()
          Nix.format.format({ force = true })
        end
      '';
      options.desc = "Format";
    }

    {
      key = "<leader>cd";
      mode = [ "n" ];
      action = "<cmd>lua vim.diagnostic.open_float()<cr>";
      options.desc = "Line Diagnostics";
    }
    {
      key = "]d";
      mode = [ "n" ];
      action.__raw = ''
        function()
          vim.diagnostic.jump({ count = vim.v.count1, float = true })
        end
      '';
      options.desc = "Next Diagnostic";
    }
    {
      key = "[d";
      mode = [ "n" ];
      action.__raw = ''
        function()
          vim.diagnostic.jump({ count = -vim.v.count1, float = true })
        end
      '';
      options.desc = "Prev Diagnostic";
    }
    {
      key = "]e";
      mode = [ "n" ];
      action.__raw = ''
        function()
          vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true })
        end
      '';
      options.desc = "Next Error";
    }
    {
      key = "[e";
      mode = [ "n" ];
      action.__raw = ''
        function()
          vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true })
        end
      '';
      options.desc = "Prev Error";
    }
    {
      key = "]w";
      mode = [ "n" ];
      action.__raw = ''
        function()
          vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true })
        end
      '';
      options.desc = "Next Warning";
    }
    {
      key = "[w";
      mode = [ "n" ];
      action.__raw = ''
        function()
          vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true })
        end
      '';
      options.desc = "Prev Warning";
    }

    {
      key = "<leader>qq";
      mode = [ "n" ];
      action = "<cmd>qa<cr>";
      options.desc = "Quit All";
    }

    {
      key = "<leader>ui";
      mode = [ "n" ];
      action = "<cmd>lua vim.show_pos()<cr>";
      options.desc = "Inspect Pos";
    }
    {
      key = "<leader>uI";
      mode = [ "n" ];
      action = "<cmd>lua vim.treesitter.inspect_tree(); vim.api.nvim_input('I')<cr>";
      options.desc = "Inspect Tree";
    }

    {
      key = "<leader>fT";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.terminal()<cr>";
      options.desc = "Terminal (cwd)";
    }
    {
      key = "<leader>ft";
      mode = [ "n" ];
      action = "<cmd>lua Snacks.terminal(nil, { cwd = Nix.root.get() })<cr>";
      options.desc = "Terminal (Root Dir)";
    }
    {
      key = "<c-/>";
      mode = [ "n" "t" ];
      action = "<cmd>lua Snacks.terminal(nil, { cwd = Nix.root.get() })<cr>";
      options.desc = "Terminal (Root Dir)";
    }
    {
      key = "<c-_>";
      mode = [ "n" "t" ];
      action = "<cmd>lua Snacks.terminal(nil, { cwd = Nix.root.get() })<cr>";
      options.desc = "which_key_ignore";
    }

    {
      key = "<leader>-";
      mode = [ "n" ];
      action = "<C-W>s";
      options = {
        remap = true;
        desc = "Split Window Below";
      };
    }
    {
      key = "<leader>|";
      mode = [ "n" ];
      action = "<C-W>v";
      options = {
        remap = true;
        desc = "Split Window Right";
      };
    }
    {
      key = "<leader>wd";
      mode = [ "n" ];
      action = "<C-W>c";
      options = {
        remap = true;
        desc = "Delete Window";
      };
    }
  ];
}
