{ pkgs, specialArgs, ... }:

{
  imports = [ ./common.nix, ./generic.nix ];

  home.homeDirectory = "/home/${specialArgs.host.username}";

  home.packages = with pkgs; [
    nixgl.nixGLIntel
    nixgl.nixVulkanIntel
    xclip
    wl-clipboard
  ];
}
