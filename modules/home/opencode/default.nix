{ ... }:

{
  imports = [
    ./caveman.nix
  ];

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
