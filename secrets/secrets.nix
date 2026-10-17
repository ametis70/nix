let
  vm-nixos-desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4w3SsDRhk3px5UgqQtfArKTartXA30NXgGffpn80XY";
  intel-nixos-server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBm5o2OnlwYvzjS7rPGlchYoZSEK4We93I5xj2Xxu0sw";
  vm-nixos-server-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBE355tY3B+HGAkEPeNitmkxkEuCjVznBpgWXM5OWU4t";
  vm-nixos-server-2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHH919ZxfzqcQTYMtKqWj01grsKcTTAKpk/ehhQYZ+KT";
  vm-nixos-server-builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWgFGFVu3xJ8ptHaMHGJ3os1nnmo4rPIdWhEUpH5e0+";
  hypervisor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP2ldIRUY1YL3NAt/9VajZNbmjImKKMwcoLmSKLAHanb";
  midtower-nixos-desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMURdmKyrZMtBCFnNgbN91A4HUCilKPvFIL5rMOHVaV4";

  allSystems = [
    vm-nixos-desktop
    intel-nixos-server
    vm-nixos-server-1
    vm-nixos-server-2
    vm-nixos-server-builder
    hypervisor
    midtower-nixos-desktop
  ];
in
{
  "k3s.age".publicKeys = allSystems;
  "nut.age".publicKeys = allSystems;
}
