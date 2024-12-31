{ pkgs, ... }:

{
  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    settings = {
      global = {
        width = 400;
        gap_size = 6;
        padding = 12;
        offset = "12x6";
        origin = "top-right";
        font = "Iosevka Medium 14";
      };

      urgency_low = {
        background = "#24283b";
        foreground = "#c0caf5";
        frame_color = "#9ece6a";
      };

      urgency_normal = {
        background = "#24283b";
        foreground = "#c0caf5";
        frame_color = "#7aa2f7";
      };

      urgency_critical = {
        background = "#24283b";
        foreground = "#f7768e";
        frame_color = "#f7768e";
      };
    };
  };
}
