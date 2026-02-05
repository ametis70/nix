{ pkgs, ... }:
{
  dependencies.gh.enable = true;

  globals = {
    mapleader = " ";
    maplocalleader = "\\";
    autoformat = true;
    snacks_animate = true;
    ai_cmp = true;
    root_spec = [
      "lsp"
      [
        ".git"
        "lua"
      ]
      "cwd"
    ];
    root_lsp_ignore = [ "copilot" ];
    deprecation_warnings = false;
    trouble_lualine = true;
    markdown_recommended_style = 0;
  };

  opts = {
    autowrite = true;
    completeopt = "menu,menuone,noselect";
    conceallevel = 2;
    confirm = true;
    cursorline = true;
    expandtab = true;

    fillchars = {
      foldopen = "";
      foldclose = "";
      fold = " ";
      foldsep = " ";
      diff = "╱";
      eob = " ";
    };

    foldlevel = 99;
    foldmethod = "indent";
    foldtext = "";

    formatoptions = "jcroqlnt";
    grepformat = "%f:%l:%c:%m";
    grepprg = "rg --vimgrep";
    ignorecase = true;
    inccommand = "nosplit";
    jumpoptions = "view";
    laststatus = 3;
    linebreak = true;
    list = true;
    mouse = "a";
    number = true;
    pumblend = 10;
    pumheight = 10;
    relativenumber = true;
    ruler = false;
    scrolloff = 4;

    sessionoptions = [
      "buffers"
      "curdir"
      "tabpages"
      "winsize"
      "help"
      "globals"
      "skiprtp"
      "folds"
    ];

    shiftround = true;
    shiftwidth = 2;
    showmode = false;
    sidescrolloff = 8;
    signcolumn = "yes";
    smartcase = true;
    smartindent = true;
    smoothscroll = false;
    spelllang = [ "en" ];
    splitbelow = true;
    splitkeep = "screen";
    splitright = true;

    tabstop = 2;
    termguicolors = true;
    undofile = true;
    undolevels = 10000;
    updatetime = 200;
    virtualedit = "block";
    wildmode = "longest:full,full";
    winminwidth = 5;
    wrap = false;

    formatexpr = "v:lua.Nix.format.formatexpr()";
    statuscolumn = "%!v:lua.statuscolumn()";

    clipboard = "unnamedplus";
  };

  extraConfigLua = ''
    vim.g.clipboard = {
      name = "osc52",
      copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
      },
      paste = {
        ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
        ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
      },
    }

    -- Extra shortmess flags.
    vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })

    -- Keep timeoutlen friendly for vscode-neovim.
    vim.opt.timeoutlen = vim.g.vscode and 1000 or 300

    function _G.statuscolumn()
      local sign = "%s"
      local n = (vim.v.relnum == 0) and tostring(vim.v.lnum) or tostring(vim.v.relnum)
      return sign .. "%=" .. n .. " "
    end
  '';

  extraPackages = with pkgs; [
    # Base tools
    fzf
    ripgrep
    fd

    # Formatters
    stylua

    # Linters
    shellcheck

    # Debuggers / build helpers
    asm-lsp
    delve
    gcc
  ];
}
