{ pkgs, ... }:

{
  imports = [
    ./nvim
    ./zk/zk.nix
    ./opencode
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
}
