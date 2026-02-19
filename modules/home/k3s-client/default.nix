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
    custom.k3s-client.enable = lib.mkEnableOption "Enable k3s remote management scripts";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "kube" (builtins.readFile ./kube.sh))
      (pkgs.writeShellScriptBin "kubesec" (builtins.readFile ./kubesec.sh))
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
      google-cloud-sdk
    ]);

    home.shellAliases = {
      "kubectl" = "kube kubectl";
      "helm" = "kube helm";
      "k9s" = "kube k9s";
      "flux" = "kube flux";
    };
  };
}
