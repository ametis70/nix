{ lib, pkgs, ... }:
{
  plugins.treesitter = {
    enable = true;
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
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
      editorconfig
      fennel
      fish
      gdscript
      gdshader
      git_config
      git_rebase
      gitattributes
      gitcommit
      gitignore
      glsl
      go
      godot_resource
      gpg
      graphql
      groovy
      html
      htmldjango
      http
      ini
      java
      javadoc
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
      nginx
      ninja
      nix
      pem
      perl
      php
      powershell
      python
      regex
      requirements
      ruby
      robots
      rust
      scss
      sql
      svelte
      sway
      terraform
      tmux
      toml
      tsx
      typescript
      typst
      udev
      vim
      vimdoc
      vue
      xml
      yaml
    ];
    settings = {
      auto_install = false;
      indent = {
        enable = true;
      };
      highlight = {
        enable = true;
      };
      folds = {
        enable = true;
      };
      ensure_installed = lib.mkForce [ ];
    };
  };

  plugins.treesitter-textobjects = {
    enable = true;
    settings = {
      move = {
        enable = true;
        set_jumps = true;
        goto_next_start = {
          "]f" = "@function.outer";
          "]c" = "@class.outer";
          "]a" = "@parameter.inner";
        };
        goto_next_end = {
          "]F" = "@function.outer";
          "]C" = "@class.outer";
          "]A" = "@parameter.inner";
        };
        goto_previous_start = {
          "[f" = "@function.outer";
          "[c" = "@class.outer";
          "[a" = "@parameter.inner";
        };
        goto_previous_end = {
          "[F" = "@function.outer";
          "[C" = "@class.outer";
          "[A" = "@parameter.inner";
        };
      };
    };
  };

  plugins.ts-autotag = {
    enable = true;
  };
}
