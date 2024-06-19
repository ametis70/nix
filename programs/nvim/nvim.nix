{ config, lib, pkgs, ... }:

let
 fromGithub = rev: ref: repo: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
      rev = rev;
    };
  };
in

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      # Deps
      ripgrep
      vim # for xxd
      gh
      nodejs_22

      # LSP
      lua-language-server
      clang-tools
      rust-analyzer
      gopls
      tailwindcss
      nodePackages.pyright
      nodePackages.vscode-json-languageserver-bin
      nodePackages.typescript-language-server

      # DAP
      # js-debug-adapter?

      # Tooling
      stylua
      shellcheck
      shfmt
      editorconfig-checker
      eslint_d
      prettierd
      python311Packages.flake8
      python311Packages.black
      rustywind
      stylelint
      html-tidy
    ];

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];

    extraLuaConfig = let
      luaRocks = with pkgs.luajitPackages; [
        luautf8
        lua-curl
        mimetypes
        xml2lua
      ];

      plugins = with pkgs.vimPlugins; [
        # Deps
        plenary-nvim
        nui-nvim
        promise-async
        nvim-web-devicons
        nvim-nio

        # Autocomplete
        copilot-lua
        { name = "LuaSnip"; path = luasnip; }
        nvim-cmp
        nvim-autopairs
        lspkind-nvim
        cmp-nvim-lsp
        cmp-nvim-lsp-signature-help
        cmp-buffer
        cmp-path
        cmp-cmdline
        cmp-omni
        cmp-git
        copilot-cmp
        cmp_luasnip
        friendly-snippets

        # Colorscheme
        tokyonight-nvim

        # Comments
        comment-nvim
        nvim-ts-context-commentstring

        # Debugging
        nvim-dap
        nvim-dap-ui

        # Files
        neo-tree-nvim
        rnvimr

        # Filetypes
        hex-nvim
        package-info-nvim
        orgmode

        # Finder
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-file-browser-nvim
        telescope-ui-select-nvim

        # Folding
        nvim-ufo

        # Git
        octo-nvim
        neogit
        gitsigns-nvim
        git-blame-nvim
        diffview-nvim

        # GUI
        dressing-nvim
        indent-blankline-nvim
        zen-mode-nvim
        twilight-nvim
        todo-comments-nvim
        nvim-colorizer-lua

        # Keybindings
        which-key-nvim

        # LSP
        mason-nvim
        mason-tool-installer-nvim
        mason-lspconfig-nvim
        fidget-nvim
        nvim-lightbulb
        aerial-nvim
        trouble-nvim
        null-ls-nvim
        nvim-lspconfig
        neoconf-nvim
        neodev-nvim
        { name = "schemastore.nvim"; path = SchemaStore-nvim; }
        typescript-nvim

        # Notes
        zk-nvim
        clipboard-image-nvim
        mkdnflow-nvim

        # Projects
        project-nvim

        # REST
        rest-nvim

        # Statusline
        { name = "incline.nvim" ; path = (fromGithub "16fc9c073e3ea4175b66ad94375df6d73fc114c0" "main" "b0o/incline.nvim"); }
        lualine-nvim

        # Term
        toggleterm-nvim

        # Testing
        { name = "neotest"; path = neotest; }
        neotest-jest
        neotest-go
        neotest-python

        # TreeSitter
        nvim-treesitter
        nvim-ts-autotag

        # Utils
        mini-nvim
        leap-nvim
        vim-repeat
        vim-table-mode
        vim-eunuch
        refactoring-nvim
      ];

      mkEntryFromDrv = drv:
        if lib.isDerivation drv then
          { name = "${lib.getName drv}"; path = drv; }
        else
          drv;

      pluginsPath = pkgs.linkFarm "nvim-plugins" (builtins.map mkEntryFromDrv plugins);

      getStorePath = drv: "${lib.getLib drv}";
      getCpath = drv: "${getStorePath drv}/lib/lua/5.1/?.so;";
      getPath = drv: "${getStorePath drv}/share/lua/5.1/?.lua;";

      luarocks.cpath = lib.concatStrings (builtins.map getCpath luaRocks);
      luarocks.path = lib.concatStrings (builtins.map getPath luaRocks);

     in
        ''
        vim.g.NIX = true
        vim.g.mapleader = " "
        vim.g.maplocalleader = ","

        package.cpath = "${luarocks.cpath}" .. package.cpath
        package.path = "${luarocks.path}" .. package.path

        require("lazy").setup({
          defaults = {
            lazy = true,
          },
          dev = {
            path = "${pluginsPath}",
            patterns = { "." },
            fallback = false,
          },
          spec = {
            { import = "plugins" },
          },
        })
        require("settings")
        '';
  };

  # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
  xdg.configFile."nvim/parser".source =
    let
      parsers = pkgs.symlinkJoin {
        name = "treesitter-parsers";
        paths = (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
          arduino
          bash
          bibtex
          c
          c_sharp
          cmake
          clojure
          commonlisp
          cpp
          css
          csv
          dart
          diff
          dockerfile
          dot
          fennel
          fish
          gdscript
          git_config
          git_rebase
          gitattributes
          gitcommit
          gitignore
          go
          gpg
          graphql
          html
          http
          ini
          java
          javascript
          jq
          jsdoc
          json
          json5
          jsonc
          kotlin
          latex
          llvm
          lua
          luadoc
          luap
          luau
          make
          markdown
          markdown_inline
          meson
          ninja
          nix
          pem
          perl
          php
          python
          requirements
          ruby
          rust
          scss
          sql
          toml
          tsx
          typescript
          vim
          vimdoc
          vue
          xml
          yaml
          org
        ])).dependencies;
      };
    in
    "${parsers}/parser";

  # Normal LazyVim config here, see https://github.com/LazyVim/starter/tree/main/lua
  xdg.configFile."nvim/lua".source = ./lua;
  xdg.configFile."nvim/.luarc.json".source = ./luarc.json;
}
