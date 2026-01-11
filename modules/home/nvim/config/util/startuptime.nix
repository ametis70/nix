{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    vim-startuptime
  ];

  extraConfigLua = ''
    vim.g.startuptime_tries = 10
  '';
}
