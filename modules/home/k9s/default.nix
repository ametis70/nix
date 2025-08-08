{
  lib,
  config,
  ...
}:

{
  programs.k9s = {
    enable = lib.mkDefault config.custom.k3s-client.enable;
    skins = {
      catppuccin-mocha = ./catppuccin-mocha.yml;
    };
    settings = {
      k9s = {
        ui = {
          skin = "catppuccin-mocha";
        };
      };
    };
  };
}
