{
  config,
  ...
}:

{
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = config.services.greetd.enable;
  security.pam.services.sshd.enableGnomeKeyring = true;
}
