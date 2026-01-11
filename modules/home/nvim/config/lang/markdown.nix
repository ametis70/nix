{ lib, pkgs, ... }:
{
  plugins.lsp.servers.marksman.enable = true;

  plugins.conform-nvim.settings = {
    formatters = {
      "markdown-toc" = {
        condition.__raw = ''
          function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
            end
          end
        '';
      };
      "markdownlint-cli2" = {
        condition.__raw = ''
          function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == "markdownlint"
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end
        '';
      };
    };
    formatters_by_ft = {
      markdown = [
        "prettier"
        "markdownlint-cli2"
        "markdown-toc"
      ];
      "markdown.mdx" = [
        "prettier"
        "markdownlint-cli2"
        "markdown-toc"
      ];
    };
  };

  plugins.lint.lintersByFt.markdown = [ "markdownlint-cli2" ];

  extraPackages = with pkgs; [
    prettier
    markdownlint-cli2
    markdown-toc
  ];

  plugins.markdown-preview.enable = true;

  plugins.render-markdown = {
    enable = true;
    settings = {
      code = {
        sign = false;
        width = "block";
        right_pad = 1;
      };
      heading = {
        sign = false;
        icons = [ ];
      };
      checkbox = {
        enabled = false;
      };
    };
  };

  keymaps = [
    {
      key = "<leader>cp";
      mode = [ "n" ];
      action = "<cmd>MarkdownPreviewToggle<cr>";
      options.desc = "Markdown Preview";
    }
  ];

  extraConfigLua = ''
    vim.filetype.add({
      extension = { mdx = "markdown.mdx" },
    })

    Snacks.toggle({
      name = "Render Markdown",
      get = require("render-markdown").get,
      set = require("render-markdown").set,
    }):map("<leader>um")
  '';
}
