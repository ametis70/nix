{ inputs, ... }:

let
  utils = import ./templates/utils.nix;
  template = import ./templates/linux.nix;
  common = {
    ram = 24;
    cpu = 12;
    disk = "archlinux.qcow2";
    mac = "52:54:00:d6:2c:03";
  };
  settings = {
    gpu = common // {
      name = "achlinux-gpu";
      uuid = "e0cb4d76-cf9f-47bf-b085-1823fab7c873";
      video = false;
      pci = with utils; [
        (pciDevice 0 42 0 1) # USB Controller function 0x1
        (pciDevice 0 42 0 3) # USB Controller function 0x3
        (pciDevice 0 35 0 0) # GPU Video
        (pciDevice 0 35 0 1) # GPU Audio
      ];
    };
    basic = common // {
      name = "archlinux";
      uuid = "0b63e87d-fec4-4014-94e5-cb19a23cf117";
      video = true;
    };
  };
in
{
  virtualisation.libvirt = {
    connections."qemu:///system" = {
      domains = [
        {
          definition = inputs.NixVirt.lib.domain.writeXML (template settings.gpu);
          active = false;
        }
        {
          definition = inputs.NixVirt.lib.domain.writeXML (template settings.basic);
          active = false;
        }
      ];
    };
  };
}
