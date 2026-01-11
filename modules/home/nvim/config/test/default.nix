{
  plugins.neotest = {
    enable = true;
    settings = {
      adapters = [ ];
      status = { virtual_text = true; };
      output = { open_on_run = true; };
      quickfix = {
        open.__raw = ''
          function()
            if package.loaded["trouble"] then
              require("trouble").open({ mode = "quickfix", focus = false })
            else
              vim.cmd("copen")
            end
          end
        '';
      };
    };
  };

  keymaps = [
    { key = "<leader>t"; mode = [ "n" ]; action = ""; options.desc = "+test"; }
    { key = "<leader>ta"; mode = [ "n" ]; action = "<cmd>lua require('neotest').run.attach()<cr>"; options.desc = "Attach to Test (Neotest)"; }
    { key = "<leader>tt"; mode = [ "n" ]; action = "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>"; options.desc = "Run File (Neotest)"; }
    { key = "<leader>tT"; mode = [ "n" ]; action = "<cmd>lua require('neotest').run.run(vim.uv.cwd())<cr>"; options.desc = "Run All Test Files (Neotest)"; }
    { key = "<leader>tr"; mode = [ "n" ]; action = "<cmd>lua require('neotest').run.run()<cr>"; options.desc = "Run Nearest (Neotest)"; }
    { key = "<leader>tl"; mode = [ "n" ]; action = "<cmd>lua require('neotest').run.run_last()<cr>"; options.desc = "Run Last (Neotest)"; }
    { key = "<leader>ts"; mode = [ "n" ]; action = "<cmd>lua require('neotest').summary.toggle()<cr>"; options.desc = "Toggle Summary (Neotest)"; }
    { key = "<leader>to"; mode = [ "n" ]; action = "<cmd>lua require('neotest').output.open({ enter = true, auto_close = true })<cr>"; options.desc = "Show Output (Neotest)"; }
    { key = "<leader>tO"; mode = [ "n" ]; action = "<cmd>lua require('neotest').output_panel.toggle()<cr>"; options.desc = "Toggle Output Panel (Neotest)"; }
    { key = "<leader>tS"; mode = [ "n" ]; action = "<cmd>lua require('neotest').run.stop()<cr>"; options.desc = "Stop (Neotest)"; }
    { key = "<leader>tw"; mode = [ "n" ]; action = "<cmd>lua require('neotest').watch.toggle(vim.fn.expand('%'))<cr>"; options.desc = "Toggle Watch (Neotest)"; }
    { key = "<leader>td"; mode = [ "n" ]; action = "<cmd>lua require('neotest').run.run({ strategy = 'dap' })<cr>"; options.desc = "Debug Nearest"; }
  ];

  extraConfigLua = ''
    local neotest_ns = vim.api.nvim_create_namespace("neotest")
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          return message
        end,
      },
    }, neotest_ns)
  '';
}
