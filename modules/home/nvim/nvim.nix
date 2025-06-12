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
      ghostscript
      mermaid-cli

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
      docker-compose-language-service
      dockerfile-language-server-nodejs
      marksman
      neocmakelsp
      nil
      ruff
      svelte-language-server
      taplo
      texlab
      vue-language-server
      vtsls
      yaml-language-server

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
      gofumpt
      markdownlint-cli2
      gotools
      sqlfluff
    ];

    extraLuaPackages = ps: [ ps.magick ];

    plugins = with specialArgs.pkgs-unstable.vimPlugins; [ lazy-nvim ];

    extraLuaConfig =
      let
        luaRocks = [ ];

        plugins = with specialArgs.pkgs-unstable.vimPlugins; [
          LazyVim

          blink-cmp
          bufferline-nvim
          catppuccin-nvim
          conform-nvim
          flash-nvim
          friendly-snippets
          gitsigns-nvim
          grug-far-nvim
          lazydev-nvim
          noice-nvim
          lualine-nvim
          mini-nvim
          nui-nvim
          nvim-lint
          nvim-lspconfig
          nvim-treesitter
          nvim-treesitter-textobjects
          nvim-ts-autotag
          persistence-nvim
          plenary-nvim
          snacks-nvim
          todo-comments-nvim
          tokyonight-nvim
          trouble-nvim
          ts-comments-nvim
          which-key-nvim
          {
            name = "mini.ai";
            path = mini-nvim;
          }
          {
            name = "mini.icons";
            path = mini-nvim;
          }
          {
            name = "mini.pairs";
            path = mini-nvim;
          }
          {
            name = "mini.surround";
            path = mini-nvim;
          }
          {
            name = "catppuccin";
            path = catppuccin-nvim;
          }
          {
            name = "blink-cmp-copilot";
            path = (
              fromGithub "439cff78780c033aa23cf061d7315314b347e3c1" "main" "giuxtaposition/blink-cmp-copilot"
            );
          }
          cmake-tools-nvim
          copilot-lua
          {
            name = "CopilotChat.nvim";
            path = (
              fromGithub "4dce4d2fc185a935024511811139b68e91b2d2a8" "main" "CopilotC-Nvim/CopilotChat.nvim"
            );
          }
          crates-nvim
          dial-nvim
          inc-rename-nvim
          markdown-preview-nvim
          {
            name = "mini.hipatterns";
            path = mini-nvim;
          }
          neotest
          neotest-golang
          neotest-python
          neotest-jest
          neotest-vitest
          nvim-dap
          nvim-dap-go
          nvim-dap-python
          nvim-dap-ui
          nvim-dap-virtual-text
          nvim-nio
          one-small-step-for-vimkind
          overseer-nvim
          render-markdown-nvim
          rustaceanvim
          {
            name = "SchemaStore.nvim";
            path = SchemaStore-nvim;
          }
          vim-dadbod
          vim-dadbod-ui
          vim-dadbod-completion
          vimtex
          yanky-nvim
          clangd_extensions-nvim
          kulala-nvim
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
        vim.g.PLUGINS_PATH = "${pluginsPath}"
        vim.g.mapleader = " "
        vim.g.maplocalleader = ","

        package.cpath = "${luarocks.cpath}" .. package.cpath
        package.path = "${luarocks.path}" .. package.path

        require("LazyVim")
      '';
  };

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
              svelte
              typst
            ]
          )).dependencies;
      };
    in
    "${parsers}/parser";

  xdg.configFile."nvim/lua".source = ./lua;
  xdg.configFile."nvim/stylua.toml".source = ../../../stylua.toml;
}
