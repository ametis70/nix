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
    home.packages =
      [
        (pkgs.writeShellScriptBin "kube" (builtins.readFile ./remote-k3s.sh))
      ]
      ++ (with pkgs; [
        kubectl
        kubernetes-helm
        k9s
        fluxcd
        kubeseal
        libsecret
        envchain
      ]);

    home.shellAliases = {
      "kubectl" = "kube kubectl";
      "helm" = "kube helm";
      "k9s" = "kube k9s";
      "flux" = "kube flux";
      "kubeseal" = "kube kubeseal";
    };
  };
}
