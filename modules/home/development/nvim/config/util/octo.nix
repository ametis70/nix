{
  plugins.octo = {
    enable = true;
    settings = {
      enable_builtin = true;
      default_to_projects_v2 = false;
      default_merge_method = "squash";
      picker = "snacks";
    };
  };

  keymaps = [
    { key = "<leader>gi"; mode = [ "n" ]; action = "<cmd>Octo issue list<CR>"; options.desc = "List Issues (Octo)"; }
    { key = "<leader>gI"; mode = [ "n" ]; action = "<cmd>Octo issue search<CR>"; options.desc = "Search Issues (Octo)"; }
    { key = "<leader>gp"; mode = [ "n" ]; action = "<cmd>Octo pr list<CR>"; options.desc = "List PRs (Octo)"; }
    { key = "<leader>gP"; mode = [ "n" ]; action = "<cmd>Octo pr search<CR>"; options.desc = "Search PRs (Octo)"; }
    { key = "<leader>gr"; mode = [ "n" ]; action = "<cmd>Octo repo list<CR>"; options.desc = "List Repos (Octo)"; }
    { key = "<leader>gS"; mode = [ "n" ]; action = "<cmd>Octo search<CR>"; options.desc = "Search (Octo)"; }

    { key = "<localleader>a"; mode = [ "n" ]; action = ""; options = { desc = "+assignee (Octo)"; }; }
    { key = "<localleader>c"; mode = [ "n" ]; action = ""; options = { desc = "+comment/code (Octo)"; }; }
    { key = "<localleader>l"; mode = [ "n" ]; action = ""; options = { desc = "+label (Octo)"; }; }
    { key = "<localleader>i"; mode = [ "n" ]; action = ""; options = { desc = "+issue (Octo)"; }; }
    { key = "<localleader>r"; mode = [ "n" ]; action = ""; options = { desc = "+react (Octo)"; }; }
    { key = "<localleader>p"; mode = [ "n" ]; action = ""; options = { desc = "+pr (Octo)"; }; }
    { key = "<localleader>pr"; mode = [ "n" ]; action = ""; options = { desc = "+rebase (Octo)"; }; }
    { key = "<localleader>ps"; mode = [ "n" ]; action = ""; options = { desc = "+squash (Octo)"; }; }
    { key = "<localleader>v"; mode = [ "n" ]; action = ""; options = { desc = "+review (Octo)"; }; }
    { key = "<localleader>g"; mode = [ "n" ]; action = ""; options = { desc = "+goto_issue (Octo)"; }; }
    { key = "@"; mode = [ "i" ]; action = "@<C-x><C-o>"; options.silent = true; }
    { key = "#"; mode = [ "i" ]; action = "#<C-x><C-o>"; options.silent = true; }
  ];

  extraConfigLua = ''
    vim.treesitter.language.register("markdown", "octo")
    vim.api.nvim_create_autocmd("ExitPre", {
      group = vim.api.nvim_create_augroup("octo_exit_pre", { clear = true }),
      callback = function()
        local keep = { "octo" }
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.tbl_contains(keep, vim.bo[buf].filetype) then
            vim.bo[buf].buftype = ""
          end
        end
      end,
    })
  '';
}
