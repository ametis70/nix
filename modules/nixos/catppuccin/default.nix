{ lib, options, ... }:

{
  catppuccin = {
    enable = true;
    flavor = "mocha";
  }
  // lib.optionalAttrs (lib.hasAttrByPath [ "catppuccin" "autoEnable" ] options) {
    autoEnable = true;
  };
}
