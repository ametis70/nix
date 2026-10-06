{
  config,
  lib,
  ...
}:

let
  cfg = config.custom.development.opencode;
in
{
  options.custom.development.opencode = {
    enable = lib.mkEnableOption "Enable OpenCode";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      opencode = {
        enable = true;
        enableMcpIntegration = true;
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
