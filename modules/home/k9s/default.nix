{
  lib,
  config,
  ...
}:

{
  programs.k9s = {
    enable = lib.mkDefault config.custom.k3s-client.enable;
  };
}
