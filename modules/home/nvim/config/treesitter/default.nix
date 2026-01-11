{ lib, ... }:
{
  plugins.treesitter = {
    enable = true;
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
