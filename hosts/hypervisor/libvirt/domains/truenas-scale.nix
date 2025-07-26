{ inputs, ... }:

let
  utils = import ./templates/utils.nix;
  template = import ./templates/linux.nix;
  settings = {
    name = "truenas-scale";
    uuid = "7cb531c2-60d7-4dfc-bb1f-b4771e5c76d6";
    ram = 16;
    cpu = 4;
    disks = [ "truenas-scale.qcow2" ];
    mac = "52:54:00:7c:23:d1";
    video = false;
    pci = with utils; [
      (pciDevice 0 44 0 0) # SATA controller
    ];
  };
in
{
  virtualisation.libvirt = {
    connections."qemu:///system" = {
      domains = [
        {
          definition = inputs.NixVirt.lib.domain.writeXML (template settings);
          active = false;
        }
      ];
    };
  };
}
