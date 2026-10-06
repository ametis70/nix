{
  plugins.kulala = {
    enable = true;
    settings = { };
  };

  plugins.treesitter.settings.ensure_installed = [ "http" "graphql" ];

  keymaps = [
    { key = "<leader>R"; mode = [ "n" ]; action = ""; options.desc = "+Rest"; }
    { key = "<leader>Rb"; mode = [ "n" ]; action = "<cmd>lua require('kulala').scratchpad()<cr>"; options.desc = "Open scratchpad"; }
    { key = "<leader>Rc"; mode = [ "n" ]; action = "<cmd>lua require('kulala').copy()<cr>"; options = { desc = "Copy as cURL"; }; }
    { key = "<leader>RC"; mode = [ "n" ]; action = "<cmd>lua require('kulala').from_curl()<cr>"; options = { desc = "Paste from curl"; }; }
    { key = "<leader>Re"; mode = [ "n" ]; action = "<cmd>lua require('kulala').set_selected_env()<cr>"; options = { desc = "Set environment"; }; }
    { key = "<leader>Rg"; mode = [ "n" ]; action = "<cmd>lua require('kulala').download_graphql_schema()<cr>"; options = { desc = "Download GraphQL schema"; }; }
    { key = "<leader>Ri"; mode = [ "n" ]; action = "<cmd>lua require('kulala').inspect()<cr>"; options = { desc = "Inspect current request"; }; }
    { key = "<leader>Rn"; mode = [ "n" ]; action = "<cmd>lua require('kulala').jump_next()<cr>"; options = { desc = "Jump to next request"; }; }
    { key = "<leader>Rp"; mode = [ "n" ]; action = "<cmd>lua require('kulala').jump_prev()<cr>"; options = { desc = "Jump to previous request"; }; }
    { key = "<leader>Rq"; mode = [ "n" ]; action = "<cmd>lua require('kulala').close()<cr>"; options = { desc = "Close window"; }; }
    { key = "<leader>Rr"; mode = [ "n" ]; action = "<cmd>lua require('kulala').replay()<cr>"; options.desc = "Replay the last request"; }
    { key = "<leader>Rs"; mode = [ "n" ]; action = "<cmd>lua require('kulala').run()<cr>"; options = { desc = "Send the request"; }; }
    { key = "<leader>RS"; mode = [ "n" ]; action = "<cmd>lua require('kulala').show_stats()<cr>"; options = { desc = "Show stats"; }; }
    { key = "<leader>Rt"; mode = [ "n" ]; action = "<cmd>lua require('kulala').toggle_view()<cr>"; options = { desc = "Toggle headers/body"; }; }
  ];

  extraConfigLua = ''
    vim.filetype.add({
      extension = {
        http = "http",
      },
    })
  '';
}
