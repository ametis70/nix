{
  plugins.copilot-chat = {
    enable = true;
    settings = {
      auto_insert_mode = true;
      question_header.__raw = ''
        "##   " .. ((vim.env.USER or "User"):sub(1, 1):upper() .. (vim.env.USER or "User"):sub(2)) .. " "
      '';
      answer_header = "##   Copilot ";
      window = {
        width = 0.4;
      };
    };
  };

  plugins.blink-cmp.settings.sources.providers.path.enabled.__raw = ''
    function()
      return vim.bo.filetype ~= "copilot-chat"
    end
  '';

  keymaps = [
    { key = "<c-s>"; mode = [ "n" ]; action = "<CR>"; options = { desc = "Submit Prompt"; remap = true; }; }
    { key = "<leader>a"; mode = [ "n" "x" ]; action = ""; options.desc = "+ai"; }
    { key = "<leader>aa"; mode = [ "n" "x" ]; action = "<cmd>lua require('CopilotChat').toggle()<cr>"; options.desc = "Toggle (CopilotChat)"; }
    { key = "<leader>ax"; mode = [ "n" "x" ]; action = "<cmd>lua require('CopilotChat').reset()<cr>"; options.desc = "Clear (CopilotChat)"; }
    { key = "<leader>aq"; mode = [ "n" "x" ]; action.__raw = ''
        function()
          vim.ui.input({ prompt = "Quick Chat: " }, function(input)
            if input ~= "" then
              require("CopilotChat").ask(input)
            end
          end)
        end
      ''; options.desc = "Quick Chat (CopilotChat)"; }
    { key = "<leader>ap"; mode = [ "n" "x" ]; action = "<cmd>lua require('CopilotChat').select_prompt()<cr>"; options.desc = "Prompt Actions (CopilotChat)"; }
  ];

  extraConfigLua = ''
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "copilot-chat",
      callback = function()
        vim.opt_local.relativenumber = false
        vim.opt_local.number = false
      end,
    })
  '';
}
