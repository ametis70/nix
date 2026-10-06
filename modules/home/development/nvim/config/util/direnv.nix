{ ... }:
{
  plugins.direnv = {
    enable = true;
  };

  extraConfigLua = ''
    local function reload_direnv()
      if vim.fn.exists(":Direnv") == 2 then
        vim.cmd("silent! Direnv")
      elseif vim.fn.exists(":DirenvReload") == 2 then
        vim.cmd("silent! DirenvReload")
      elseif vim.fn.exists(":DirenvUpdate") == 2 then
        vim.cmd("silent! DirenvUpdate")
      end
    end

    local group = vim.api.nvim_create_augroup("nix_direnv_reload", { clear = true })

    vim.api.nvim_create_autocmd("DirChanged", {
      group = group,
      callback = reload_direnv,
    })

    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "ProjectChanged",
      callback = reload_direnv,
    })
  '';
}
