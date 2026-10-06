{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.homelab.client;
in
{
  options = {
    custom.homelab.client.enable = lib.mkEnableOption "Enable k3s remote management scripts";
  };

  imports = [ ./k9s.nix ];

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "kube" (builtins.readFile ./kube.sh))
      (pkgs.writeShellScriptBin "kubemail" (builtins.readFile ./kubemail.sh))
    ]
    ++ (with pkgs; [
      kubectl
      kubectl-cnpg
      kubeconform
      kustomize
      kubernetes-helm
      k9s
      fluxcd
      libsecret
      envchain
    ]);

    home.shellAliases = {
      "kubectl" = "kube kubectl";
      "helm" = "kube helm";
      "k9s" = "kube k9s";
      "flux" = "kube flux";
    };
  };
}
