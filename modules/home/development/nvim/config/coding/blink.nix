{ lib, ... }:
{
  plugins.blink-cmp = {
    enable = true;
    setupLspCapabilities = true;
    settings = {
      snippets = {
        preset = lib.mkDefault "default";
        expand.__raw = "Nix.cmp.expand";
      };

      appearance = {
        use_nvim_cmp_as_default = false;
        nerd_font_variant = "mono";
        kind_icons.__raw = "Nix.icons.kinds";
      };

      completion = {
        accept = {
          auto_brackets = {
            enabled = true;
          };
        };
        menu = {
          draw = {
            treesitter = [ "lsp" ];
          };
        };
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 200;
        };
        ghost_text = {
          enabled.__raw = "vim.g.ai_cmp";
        };
      };

      sources = {
        compat = [ ];
        default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
        per_filetype = {
          lua = [ "lazydev" ];
        };
        providers = {
          lazydev = {
            name = "LazyDev";
            module = "lazydev.integrations.blink";
            score_offset = 100;
          };
        };
      };

      cmdline = {
        enabled = true;
        keymap = {
          preset = "cmdline";
          "<Right>" = false;
          "<Left>" = false;
        };
        completion = {
          list = {
            selection = {
              preselect = false;
            };
          };
          menu = {
            auto_show.__raw = ''
              function()
                return vim.fn.getcmdtype() == ":"
              end
            '';
          };
          ghost_text = {
            enabled = true;
          };
        };
      };

      keymap = {
        preset = "enter";
        "<C-y>" = [ "select_and_accept" ];
        "<Tab>" = [
          {
            __raw = "Nix.cmp.map({ 'snippet_forward', 'ai_nes', 'ai_accept' })";
          }
          "fallback"
        ];
      };
    };
  };
}
