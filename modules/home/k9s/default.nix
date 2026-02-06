{
  lib,
  config,
  pkgs,
  ...
}:

{
  programs.k9s = {
    enable = lib.mkDefault config.custom.k3s-client.enable;
  };

  xdg.configFile =
    let
      k9sPluginsSrc = pkgs.fetchFromGitHub {
        owner = "derailed";
        repo = "k9s";
        rev = "20cac12c2a2b85b3bab2777d99dce474213b9a62";
        sha256 = "066b5kv46agi13pckyzq0p1nbm1sh2cprkfzlqa9bplq0d757qs5";
      };
    in
    {
      "k9s/plugins/get-all-namespace-resources.yaml".text =
        builtins.readFile "${k9sPluginsSrc}/plugins/get-all-namespace-resources.yaml";
      "k9s/plugins/flux.yaml".text = builtins.readFile "${k9sPluginsSrc}/plugins/flux.yaml";
    };
}
