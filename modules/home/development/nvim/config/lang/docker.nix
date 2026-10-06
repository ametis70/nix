{ lib, pkgs, ... }:
{
  plugins.treesitter.settings.ensure_installed = lib.mkAfter [ "dockerfile" ];

  plugins.lsp.servers = {
    dockerls.enable = true;
    docker_compose_language_service.enable = true;
  };

  plugins.lint.lintersByFt.dockerfile = [ "hadolint" ];

  extraPackages = with pkgs; [
    hadolint
  ];
}
