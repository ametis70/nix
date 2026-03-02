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
    opencode
  ];
}
