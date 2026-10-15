{ host, ... }:

{
  nix.settings = {
    trusted-users = [ "${host.username}" ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  system.copySystemConfiguration = false;
}
