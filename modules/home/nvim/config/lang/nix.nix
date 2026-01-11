{ lib, pkgs, ... }:
{
  plugins.treesitter.settings.ensure_installed = lib.mkAfter [ "nix" ];

  plugins.lsp.servers.nil_ls.enable = true;

  plugins.conform-nvim.settings.formatters_by_ft.nix = [ "nixfmt" ];
  plugins.lint.lintersByFt.nix = [ "statix" ];

  extraPackages = with pkgs; [
    nixfmt-rfc-style
    statix
  ];
}
