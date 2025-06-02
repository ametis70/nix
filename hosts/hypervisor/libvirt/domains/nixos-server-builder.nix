{ inputs, ... }:

let
  template = import ./templates/linux.nix;
  settings = {
    name = "nixos-server-builder";
    uuid = "b84845a4-423d-48f9-b0cc-5ead175b57a9";
    video = true;
    ram = 16;
    cpu = 4;
    disks = [
      "server-builder.qcow2"
    ];
    mac = "6e:75:ef:46:ed:26";
  };
in
{
  virtualisation.libvirt = {
    connections."qemu:///system" = {
      domains = [
        {
          definition = inputs.NixVirt.lib.domain.writeXML (template settings);
          active = true;
        }
      ];
    };
  };
}
