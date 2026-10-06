{
  plugins.inc-rename = {
    enable = true;
  };

  plugins.noice.settings.presets.inc_rename = true;

  keymaps = [
    {
      key = "<leader>cr";
      mode = [ "n" ];
      action.__raw = ''
        function()
          local inc_rename = require("inc_rename")
          return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
        end
      '';
      options = {
        expr = true;
        desc = "Rename (inc-rename.nvim)";
      };
    }
  ];
}
