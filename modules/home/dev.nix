{ pkgs, ... }:

{
  imports = [
    ./nvim/nvim.nix
    ./zk/zk.nix
  ];

  home.packages = with pkgs; [
    codex
  ];
}
