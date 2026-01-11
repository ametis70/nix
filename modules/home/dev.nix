{ pkgs, ... }:

{
  imports = [
    ./nvim
    ./zk/zk.nix
  ];

  home.packages = with pkgs; [
    codex
  ];
}
