{ lib, ... }:
{
  plugins.copilot-lua = {
    enable = true;
    settings = {
      suggestion = {
        enabled.__raw = "not vim.g.ai_cmp";
        auto_trigger = true;
        hide_during_completion.__raw = "vim.g.ai_cmp";
        keymap = {
          accept = false;
          next = "<M-]>";
          prev = "<M-[>";
        };
      };
      panel = { enabled = false; };
      filetypes = {
        markdown = true;
        help = true;
      };
    };
  };

  plugins.lsp.servers.copilot.enable = lib.mkDefault false;

  extraConfigLua = ''
    Nix.cmp.actions.ai_accept = function()
      if require("copilot.suggestion").is_visible() then
        Nix.create_undo()
        require("copilot.suggestion").accept()
        return true
      end
    end

    local ok, lualine = pcall(require, "lualine")
    local has_sidekick = pcall(require, "sidekick.status")
    if ok and not has_sidekick then
      local cfg = lualine.get_config()
      table.insert(cfg.sections.lualine_x, 2, Nix.lualine.status(Nix.icons.kinds.Copilot, function()
        local clients = package.loaded["copilot"] and vim.lsp.get_clients({ name = "copilot", bufnr = 0 }) or {}
        if #clients > 0 then
          local status = require("copilot.status").data.status
          return (status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok"
        end
      end))
      lualine.setup(cfg)
    end
  '';
}
