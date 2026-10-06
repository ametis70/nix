{ pkgs, ... }:
{
  extraPackages = with pkgs; [
    fish
    shfmt
    shellcheck
  ];
}
