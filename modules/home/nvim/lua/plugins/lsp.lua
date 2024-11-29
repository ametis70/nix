local config_lsp = function()
  local wk = require("which-key")

  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

  local lsp_rename_mapping = {
    function()
      vim.lsp.buf.rename()
    end,
    "Rename LSP symbol",
  }
  local lsp_references_mapping = {
    "<cmd>TroubleToggle lsp_references<CR>",
    "LSP references",
  }

  local on_attach = function(client, bufnr)
    vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })

    -- Normal mappings
    wk.register({
      c = {
        a = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code action" },
        r = lsp_rename_mapping,
        f = {
          "<cmd>lua vim.lsp.buf.format()<CR>",
          "Format file",
        },
        o = { "<cmd>AerialToggle!<CR>", "Toggle outline" },
        x = { "<cmd>lua vim.diagnostic.open_float({source= true})<CR>", "Show line diagnostics" },
        R = lsp_references_mapping,
        t = {
          name = "Trouble",
          t = { "<cmd>TroubleToggle<CR>", "Trouble Toggle" },
          r = lsp_references_mapping,
          w = { "<cmd>TroubleToggle lsp_workspace_diagnostics<CR>", "Workspace diagnostics" },
          d = { "<cmd>TroubleToggle lsp_document_diagnostics<CR>", "Document diagnostics" },
          q = { "<cmd>TroubleToggle quickfix<CR>", "Quickfix" },
          l = { "<cmd>TroubleToggle loclist<CR>", "Location list" },
        },
        g = {
          name = "Go to",
          D = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "Go to declaration" },
          d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Go to definition" },
          i = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "Go to implementation" },
          t = { "<cmd>lua vim.lsp.buf.type_definition()<CR>", "Go to type definition" },
        },
      },
    }, {
      prefix = "<leader>",
      buffer = bufnr,
    })

    -- Visual mappings
    wk.register({
      c = {
        a = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "Range code action" },
        f = {
          "<cmd>lua vim.lsp.buf.format()<CR>",
          "Range formatting",
        },
      },
    }, {
      mode = "v",
      prefix = "<leader>",
      buffer = bufnr,
    })

    -- No leader mappings
    wk.register({
      gd = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Go to definition" },
      K = { "<cmd>lua vim.lsp.buf.hover()<CR>", "LSP Hover" },
      ["<C-k"] = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "LSP Signature" },
      ["<f2>"] = lsp_rename_mapping,
      ["[["] = { "<cmd>AerialPrevUp<CR>", "Outline previous" },
      ["]]"] = { "<cmd>AerialNext<CR>", "Outline next" },
    }, {
      buffer = bufnr,
    })

    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          if vim.g.format_on_save == 1 then
            vim.lsp.buf.format({ bufnr = bufnr })
          end
        end,
      })
    end
  end

  local settings = {
    capabilities = capabilities,
    on_attach = on_attach,
  }

  local servers = {
    "clangd",
    "pyright",
    "rust_analyzer",
    "gopls",
    "eslint",
    "html",
    "cssls",
    "cssmodules_ls",
    "tailwindcss",
    "lua_ls",
    "nixd",
    "bashls",
  }

  for _, lsp in pairs(servers) do
    require("lspconfig")[lsp].setup(settings)
  end

  -- JSON
  require("lspconfig").jsonls.setup(vim.tbl_deep_extend("force", settings, {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        validate = {
          enable = true,
        },
      },
    },
  }))

  -- Typescript
  require("typescript").setup({
    disable_commands = false,
    debug = false,
    server = settings,
  })
end

return {
  {
    "williamboman/mason.nvim",
    enable = vim.g.NIX and false or true,
    config = true,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    enable = vim.g.NIX and false or true,
    config = true,
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "editorconfig-checker",
        "prettier",
        "prettierd",
        "eslint",
        "flake8",
        "black",
        "js-debug-adapter",
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    enable = vim.g.NIX and false or true,
    config = true,
    opts = {
      automatic_installation = true,
    },
  },
  {
    "kosayoda/nvim-lightbulb",
    opts = {
      autocmd = {
        enabled = false,
      },
      sign = {
        enabled = false,
      },
      virtual_text = {
        enabled = false,
      },
    },
  },
  {
    "stevearc/aerial.nvim",
    opts = {},
    cmd = "AerialToggle",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
  { "folke/trouble.nvim", config = true, cmd = { "TroubleToggle", "Trouble" } },
  {
    "nvimtools/none-ls.nvim",
    dependencies = vim.g.NIX and { "nvimtools/none-ls-extras.nvim" }
        or { "williamboman/mason.nvim", "nvimtools/none-ls-extras.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      vim.g.format_on_save = 1

      function _G.toggle_format_on_save()
        if vim.g.format_on_save == 1 then
          vim.g.format_on_save = 0
          print("Disabled format on save")
        else
          vim.g.format_on_save = 1
          print("Enabled format on save")
        end
      end
    end,
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        timeout_ms = 5000,
        sources = {
          -- General
          null_ls.builtins.code_actions.refactoring,
          null_ls.builtins.diagnostics.trail_space,
          require("none-ls.formatting.trim_newlines"),
          require("none-ls.formatting.trim_whitespace"),

          -- Git
          null_ls.builtins.code_actions.gitrebase,
          null_ls.builtins.code_actions.gitsigns,

          -- GitHub
          null_ls.builtins.diagnostics.actionlint,

          -- Shell
          null_ls.builtins.formatting.shfmt,

          -- C/C++
          null_ls.builtins.formatting.clang_format,
          null_ls.builtins.formatting.cmake_format,

          -- Web
          null_ls.builtins.formatting.prettierd,
          null_ls.builtins.diagnostics.stylelint,
          null_ls.builtins.formatting.stylelint,
          null_ls.builtins.formatting.rustywind,

          -- Markdown
          null_ls.builtins.formatting.remark,

          -- Lua
          null_ls.builtins.formatting.stylua,

          -- Python
          require("none-ls.diagnostics.flake8"),
          null_ls.builtins.formatting.black,
          null_ls.builtins.formatting.isort,

          -- Go
          null_ls.builtins.formatting.gofmt,

          -- Nix
          null_ls.builtins.formatting.nixfmt,
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "folke/neoconf.nvim", cmd = "Neoconf", config = false, dependencies = { "nvim-lspconfig" } },
      {
        "folke/lazydev.nvim",
        ft = "lua",
        config = true,
      },
      "kosayoda/nvim-lightbulb",
      "hrsh7th/cmp-nvim-lsp",
      "b0o/schemastore.nvim",
      "jose-elias-alvarez/typescript.nvim",
      vim.g.NIX and nil or "mason.nvim",
      vim.g.NIX and nil or "williamboman/mason-lspconfig.nvim",
    },
    config = config_lsp,
  },
}
