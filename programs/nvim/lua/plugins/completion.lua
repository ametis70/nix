local setup_cmp = function()
  local lspkind = require("lspkind")
  local luasnip = require("luasnip")
  local cmp = require("cmp")

  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  cmp.setup({
    confirm_opts = {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    formatting = {
      format = lspkind.cmp_format({
        mode = "symbol_text",
        maxwidth = 50,
        before = function(_, vim_item)
          return vim_item
        end,
      }),
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({
        select = false,
      }),

      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          -- cmp.complete()
          fallback()
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),

    sources = cmp.config.sources({
      { name = "copilot" },
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "nvim_lsp_signature_help" },
      { name = "nvim_lua" },
      { name = "orgmode" },
      { name = "path" },
      { name = "buffer" },
    }),
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({
      { name = "cmp_git" },
    }, {
      { name = "buffer" },
    }),
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      {
        name = "buffer",
      },
    },
  })
end

return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    init = function()
      vim.o.completeopt = "menu,menuone,noselect"
    end,
    config = setup_cmp,
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "onsails/lspkind-nvim", -- Pretty icons
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-omni",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "saadparwaiz1/cmp_luasnip",
      { "petertriho/cmp-git", config = true },
      {
        "zbirenbaum/copilot-cmp",
        dependencies = { "zbirenbaum/copilot.lua" },
        config = true,
      },
    },
  },
  {
    "L3MON4D3/LuaSnip",
    version = "2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
  },
}
