{
  lib,
  pkgs,
  specialArgs,
  ...
}:

let
  fromGithub =
    rev: ref: repo:
    pkgs.vimUtils.buildVimPlugin {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      version = ref;
      src = builtins.fetchGit {
        url = "https://github.com/${repo}";
        ref = ref;
        rev = rev;
      };
      doCheck = false;
    };
in

{
  programs.neovim = {
    enable = true;
    package = specialArgs.pkgs-unstable.neovim-unwrapped;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with specialArgs.pkgs-unstable; [
      # Deps
      ripgrep
      tinyxxd
      gh
      nodejs_22
      luarocks
      lua51Packages.lua
      imagemagick

      # LSP
      nixd
      lua-language-server
      clang-tools
      rust-analyzer
      gopls
      tailwindcss-language-server
      vscode-langservers-extracted
      pyright
      nodePackages.typescript-language-server
      nodePackages.bash-language-server

      # DAP
      vscode-js-debug

      # Tooling
      stylua
      shellcheck
      shfmt
      editorconfig-checker
      eslint_d
      nodePackages.eslint
      prettierd
      nodePackages.prettier
      python312Packages.flake8
      python312Packages.black
      rustywind
      stylelint
      html-tidy
      nixfmt-rfc-style
      rustfmt
      gawk
    ];

    extraLuaPackages = ps: [ ps.magick ];

    plugins = with specialArgs.pkgs-unstable.vimPlugins; [ lazy-nvim ];

    extraLuaConfig =
      let
        luaRocks = with specialArgs.pkgs-unstable.luajitPackages; [
          luautf8
          lua-curl
          mimetypes
          xml2lua
        ];

        plugins = with specialArgs.pkgs-unstable.vimPlugins; [
          # Deps
          plenary-nvim
          nui-nvim
          promise-async
          nvim-web-devicons
          nvim-nio
          nvim-window-picker
          {
            name = "neovim-session-manager";
            path = (
              fromGithub "3409dc920d40bec4c901c0a122a80bee03d6d1e1" "master" "Shatur/neovim-session-manager"
            );
          }

          # Autocomplete
          copilot-lua
          {
            name = "LuaSnip";
            path = luasnip;
          }
          nvim-cmp
          nvim-autopairs
          {
            name = "lspkind-nvim";
            path = lspkind-nvim;
          }
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
          {
            name = "Comment.nvim";
            path = comment-nvim;
          }
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
          nvim-notify
          noice-nvim
          alpha-nvim
          fidget-nvim

          # Keybindings
          which-key-nvim

          # LSP
          mason-nvim
          mason-tool-installer-nvim
          mason-lspconfig-nvim
          nvim-lightbulb
          aerial-nvim
          trouble-nvim
          none-ls-nvim
          {
            name = "none-ls-extras.nvim";
            path = (
              fromGithub "6557f20e631d2e9b2a9fd27a5c045d701a3a292c" "main" "nvimtools/none-ls-extras.nvim"
            );
          }
          nvim-lspconfig
          neoconf-nvim
          lazydev-nvim
          {
            name = "schemastore.nvim";
            path = SchemaStore-nvim;
          }
          typescript-nvim

          # Notes
          zk-nvim
          clipboard-image-nvim
          mkdnflow-nvim

          # Projects
          {
            name = "neovim-project";
            path = (fromGithub "3ca01f19a6405334bf1f652126e63f1229ad0e74" "main" "coffebar/neovim-project");
          }

          # REST
          rest-nvim

          # Statusline
          {
            name = "incline.nvim";
            path = (fromGithub "0eb5b7f6fc6636a4e7b2eb2800b7650fd6d164a2" "main" "b0o/incline.nvim");
          }
          lualine-nvim

          # Term
          toggleterm-nvim

          # Testing
          neotest
          neotest-jest
          neotest-go
          neotest-python

          # TreeSitter
          nvim-treesitter
          nvim-ts-autotag

          # Utils
          snacks-nvim
          mini-nvim
          leap-nvim
          vim-repeat
          vim-table-mode
          vim-eunuch
          refactoring-nvim
        ];

        mkEntryFromDrv =
          drv:
          if lib.isDerivation drv then
            {
              name = "${lib.getName drv}";
              path = drv;
            }
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
        vim.g.NIX_USER = "${specialArgs.host.username}"
        vim.g.NIX_HOST = "${specialArgs.host.hostname}"
        vim.g.NIXOS = ${if specialArgs.host.nixos then "true" else "false"}
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
        paths =
          (specialArgs.pkgs-unstable.vimPlugins.nvim-treesitter.withPlugins (
            plugins: with plugins; [
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
              regex
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
              http
            ]
          )).dependencies;
      };
    in
    "${parsers}/parser";

  # Normal LazyVim config here, see https://github.com/LazyVim/starter/tree/main/lua
  xdg.configFile."nvim/lua".source = ./lua;
  xdg.configFile."nvim/stylua.toml".source = ../../../stylua.toml;
}
