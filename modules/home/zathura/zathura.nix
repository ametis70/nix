{ lib, config, ... }:

{
  xdg.mimeApps = lib.mkIf config.xdg.mimeApps.enable {
    associations.added = {
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
    };
    defaultApplications = {
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
    };
  };

  programs.zathura = {
    enable = true;

    options = {
      adjust-open = "best-fit";
      pages-per-row = 1;
      scroll-page-aware = "true";
      scroll-full-overlap = "0.01";
      zoom-min = 10;
      guioptions = "s";
      font = "Iosevka Medium 14";
      recolor = true;
      recolor-keephue = false;
      render-loading = true;
      scroll-step = 50;
      selection-clipboard = "clipboard";
      sandbox = "none";
      notification-error-bg = "#f7768e";
      notification-error-fg = "#c0caf5";
      notification-warning-bg = "#e0af68";
      notification-warning-fg = "#414868";
      notification-bg = "#24283b";
      notification-fg = "#c0caf5";
      completion-bg = "#24283b";
      completion-fg = "#a9b1d6";
      completion-group-bg = "#24283b";
      completion-group-fg = "#a9b1d6";
      completion-highlight-bg = "#414868";
      completion-highlight-fg = "#c0caf5";
      index-bg = "#24283b";
      index-fg = "#c0caf5";
      index-active-bg = "#414868";
      index-active-fg = "#c0caf5";
      inputbar-bg = "#24283b";
      inputbar-fg = "#c0caf5";
      statusbar-bg = "#24283b";
      statusbar-fg = "#c0caf5";
      highlight-color = "#e0af68";
      highlight-active-color = "#9ece6a";
      default-bg = "#24283b";
      default-fg = "#c0caf5";
      render-loading-fg = "#24283b";
      render-loading-bg = "#c0caf5";
      recolor-lightcolor = "#24283b";
      recolor-darkcolor = "#c0caf5";
    };
  };
}
