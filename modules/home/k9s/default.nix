{
  ...
}:

{
  programs.k9s = {
    enable = true;
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
