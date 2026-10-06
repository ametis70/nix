{
  plugins.conform-nvim = {
    enable = true;
    settings = {
      default_format_opts = {
        timeout_ms = 3000;
        async = false;
        quiet = false;
        lsp_format = "fallback";
      };
      formatters_by_ft = {
        lua = [ "stylua" ];
        fish = [ "fish_indent" ];
        sh = [ "shfmt" ];
        css = [ "prettier" ];
        graphql = [ "prettier" ];
        handlebars = [ "prettier" ];
        html = [ "prettier" ];
        javascript = [ "prettier" ];
        javascriptreact = [ "prettier" ];
        json = [ "prettier" ];
        jsonc = [ "prettier" ];
        less = [ "prettier" ];
        scss = [ "prettier" ];
        svelte = [ "prettier" ];
        typescript = [ "prettier" ];
        typescriptreact = [ "prettier" ];
        vue = [ "prettier" ];
        yaml = [ "prettier" ];
      };
      formatters = {
        injected = {
          options = {
            ignore_errors = true;
          };
        };
        prettier = {
          condition.__raw = ''
            function(_, ctx)
              local supported = {
                "css",
                "graphql",
                "handlebars",
                "html",
                "javascript",
                "javascriptreact",
                "json",
                "jsonc",
                "less",
                "markdown",
                "markdown.mdx",
                "scss",
                "svelte",
                "typescript",
                "typescriptreact",
                "vue",
                "yaml",
              }
              local ft = vim.bo[ctx.buf].filetype
              local has_parser = vim.tbl_contains(supported, ft)
              if not has_parser then
                local ret = vim.fn.system({ "prettier", "--file-info", ctx.filename })
                local ok, parser = pcall(function()
                  return vim.fn.json_decode(ret).inferredParser
                end)
                has_parser = ok and parser and parser ~= vim.NIL
              end
              if not has_parser then
                return false
              end
              if vim.g.lazyvim_prettier_needs_config == true then
                vim.fn.system({ "prettier", "--find-config-path", ctx.filename })
                return vim.v.shell_error == 0
              end
              return true
            end
          '';
        };
      };
    };
  };

  extraConfigLua = ''
    Nix.format.register({
      name = "conform.nvim",
      priority = 100,
      primary = true,
      format = function(buf)
        require("conform").format({ bufnr = buf })
      end,
      sources = function(buf)
        local ret = require("conform").list_formatters(buf)
        return vim.tbl_map(function(v)
          return v.name
        end, ret)
      end,
    })

    Nix.format.register({
      name = "eslint: lsp",
      priority = 200,
      primary = false,
      format = function(buf)
        vim.lsp.buf.format({ bufnr = buf, filter = function(client)
          return client.name == "eslint"
        end })
      end,
      sources = function(buf)
        local clients = vim.lsp.get_clients({ bufnr = buf })
        local has_eslint = false
        for _, client in ipairs(clients) do
          if client.name == "eslint" then
            has_eslint = true
            break
          end
        end
        return has_eslint and { "eslint" } or {}
      end,
    })

    Nix.format.setup()
  '';
}
