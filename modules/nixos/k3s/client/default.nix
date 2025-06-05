{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.k3s-client;
in
{
  options = {
    custom.k3s-client.enable = lib.mkEnableOption "Enable k3s remote management script";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      [
        (pkgs.writeShellScriptBin "kube" (builtins.readFile ./remote-k3s.sh))
      ]
      ++ (with pkgs; [
        kubectl
        kubernetes-helm
        k9s
        libsecret
      ]);
  };
}
