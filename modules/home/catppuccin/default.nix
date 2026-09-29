{ lib, options, ... }:

{
  catppuccin = {
    enable = true;
    flavor = "mocha";

    nvim.enable = false;
    gtk.icon.enable = false;
    kvantum.enable = false;
    hyprland.enable = false;

  }
  // lib.optionalAttrs (lib.hasAttrByPath [ "catppuccin" "autoEnable" ] options) {
    autoEnable = true;
  };

}
