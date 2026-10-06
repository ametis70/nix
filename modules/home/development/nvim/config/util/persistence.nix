{
  plugins.persistence = {
    enable = true;
    settings = { };
  };

  keymaps = [
    { key = "<leader>qs"; mode = [ "n" ]; action = "<cmd>lua require('persistence').load()<cr>"; options.desc = "Restore Session"; }
    { key = "<leader>qS"; mode = [ "n" ]; action = "<cmd>lua require('persistence').select()<cr>"; options.desc = "Select Session"; }
    { key = "<leader>ql"; mode = [ "n" ]; action = "<cmd>lua require('persistence').load({ last = true })<cr>"; options.desc = "Restore Last Session"; }
    { key = "<leader>qd"; mode = [ "n" ]; action = "<cmd>lua require('persistence').stop()<cr>"; options.desc = "Don't Save Current Session"; }
  ];
}
