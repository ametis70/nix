{
  plugins.mini = {
    enable = true;
    mockDevIcons = true;
    modules = {
      ai = {
        n_lines = 50;
        search_method = "cover_or_next";
      };
      pairs = { };
      comment = {
        mappings = {
          comment = "<leader>/";
          comment_line = "<leader>/";
          comment_visual = "<leader>/";
          textobject = "<leader>/";
        };
      };
      snippets = { };
      surround = {
        mappings = {
          add = "gsa";
          delete = "gsd";
          find = "gsf";
          find_left = "gsF";
          highlight = "gsh";
          replace = "gsr";
          update_n_lines = "gsn";
        };
      };
      diff = {
        view = {
          style = "sign";
        };
      };
      move = { };
      icons = { };
    };
  };
}
