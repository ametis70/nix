{
  plugins.mini-icons = {
    enable = true;
    mockDevIcons = true;
    settings = {
      file = {
        ".keep" = { glyph = "󰊢"; hl = "MiniIconsGrey"; };
        "devcontainer.json" = { glyph = ""; hl = "MiniIconsAzure"; };
      };
      filetype = {
        dotenv = { glyph = ""; hl = "MiniIconsYellow"; };
      };
    };
  };
}
