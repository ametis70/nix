{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.custom.dev;
in
{
  options.custom.dev.enable = lib.mkEnableOption "development environment (toolchains, opencode, mcp, neovim, zk)";

  config = lib.mkIf cfg.enable {
    # nvim (nixvim) and zk used to be pulled in via imports; they are now
    # auto-discovered option modules that dev turns on.
    custom.nvim.enable = lib.mkDefault true;
    custom.zk.enable = lib.mkDefault true;

    home.packages = with pkgs; [
      nodejs
      pnpm
      go
      python3
      codex
    ];

    home.sessionVariables = {
      OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";
      OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
    };

    programs = {
      opencode = {
        enable = true;
        enableMcpIntegration = true;
        settings = {
          permission = {
            lsp = "allow";
          };
        };
      };
      mcp = {
        enable = true;
        servers = {
          exa = {
            url = "https://mcp.exa.ai/mcp";
          };
          context7 = {
            url = "https://mcp.context7.com/mcp";
          };
          grep-app = {
            url = "https://mcp.grep.app";
          };
        };
      };
    };
  };
}
