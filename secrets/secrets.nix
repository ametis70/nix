let
  system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4w3SsDRhk3px5UgqQtfArKTartXA30NXgGffpn80XY";
  system2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyy8MljGwjygWJSeuoVDAcL+vyqFT/SHO1YqAk2l64B";
  system3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBm5o2OnlwYvzjS7rPGlchYoZSEK4We93I5xj2Xxu0sw";
  system4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBE355tY3B+HGAkEPeNitmkxkEuCjVznBpgWXM5OWU4t";
  system5 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHH919ZxfzqcQTYMtKqWj01grsKcTTAKpk/ehhQYZ+KT";
  system6 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWgFGFVu3xJ8ptHaMHGJ3os1nnmo4rPIdWhEUpH5e0+";
  system7 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP2ldIRUY1YL3NAt/9VajZNbmjImKKMwcoLmSKLAHanb";

  allSystems = [
    system1
    system2
    system3
    system4
    system5
    system6
    system7
  ];
in
{
  "k3s.age".publicKeys = allSystems;
  "nut.age".publicKeys = allSystems;
}
