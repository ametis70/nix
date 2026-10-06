{
  plugins.project-nvim = {
    enable = true;
    settings = {
      manual_mode = true;
    };
  };

  extraConfigLua = ''
    local ok, history = pcall(require, "project_nvim.utils.history")
    if ok then
      history.delete_project = function(project)
        for k, v in pairs(history.recent_projects) do
          if v == project.value then
            history.recent_projects[k] = nil
            return
          end
        end
      end
    end
  '';
}
