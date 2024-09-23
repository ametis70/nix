{ pkgs, ... }:

{
  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  users.users.ametis70 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdeXLsyF3y5W8Xy/MI5G0qttr+7M+Opd03w7dzrJLJ7"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzcytKRVeHivinYCOL2BmSKAXyA0phU55ZF8hzkc43Z"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAvjO5PcjSiiAnAV3oRFDNgzGiV7HdlkocRw6uJCs0/w"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDA07n+GRqAPcZa8EGh4LvF57RjUOHXdp+942VJrjWqk"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTMwKGTiKKaOXosdBnAlCl7MC6CT8JAI1nZsB/1VLKV"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWznt23SwzkAuVook9PU9fvYvbvmFpoxhPTzHRnTvNI"
    ];
  };
}
