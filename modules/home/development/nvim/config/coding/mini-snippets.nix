{
  plugins.friendly-snippets.enable = true;

  plugins.mini-snippets = {
    enable = true;
    settings = {
      snippets = [
        {
          __raw = "require('mini.snippets').gen_loader.from_lang()";
        }
      ];
      expand = {
        select.__raw = ''
          function(snippets, insert)
            local select = _G.NixMiniSnippetsSelectOverride or MiniSnippets.default_select
            select(snippets, insert)
          end
        '';
      };
    };
  };

  plugins.blink-cmp.settings.snippets.preset = "mini_snippets";

  extraConfigLua = ''
    local MiniSnippets = require("mini.snippets")

    local function jump(direction)
      local is_active = MiniSnippets.session.get(false) ~= nil
      if is_active then
        MiniSnippets.session.jump(direction)
        return true
      end
    end

    Nix.cmp.actions.snippet_stop = function()
      -- keep session alive on <esc>
    end

    Nix.cmp.actions.snippet_forward = function()
      return jump("next")
    end
  '';
}
