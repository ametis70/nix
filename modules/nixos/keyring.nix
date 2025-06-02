{
  config,
  ...
}:

{
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = config.services.greetd.enable;
  environment.variables.SSH_AUTH_SOCK = "/run/user/$UID/keyring/ssh";
}
