{ pkgs, ... }:

{
  imports = [
    ./nvim
    ./zk/zk.nix
  ];

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
}
