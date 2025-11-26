let
  isAbsolute = path: path != "" && builtins.substring 0 1 path == "/";
in
{

  mkPCIHostDevs = builtins.map (dev: {
    mode = "subsystem";
    type = "pci";
    managed = true;
    driver = {
      name = "vfio";
    };
    source = {
      address = {
        domain = dev.domain;
        bus = dev.bus;
        slot = dev.slot;
        function = dev.function;
      };
    };
  });

  mkDisks = builtins.map (
    disk:
    let
      isStr = builtins.isString disk;
      isSet = builtins.isAttrs disk;

      name =
        if isStr then
          disk
        else
          (if isSet && (builtins.hasAttr "name" disk) then disk.name else throw "Disk name is required");
      driver =
        if isSet && (builtins.hasAttr "driver" disk) then
          disk.driver
        else
          {
            name = "qemu";
            type = "qcow2";
            cache = "none";
            discard = "unmap";
          };
      target = if isSet && (builtins.hasAttr "target" disk) then disk.target else "vda";
      bus = if isSet && (builtins.hasAttr "bus" disk) then disk.bus else "virtio";
    in
    if !isStr && !isSet then
      throw "Disk is not string or set"
    else
      {
        type = if isSet && (builtins.hasAttr "type" disk) then disk.type else "file";
        device = "disk";
        driver = driver;
        source = {
          file = if (isAbsolute name) then name else "/var/lib/libvirt/images/${name}";
        };
        target = {
          dev = target;
          bus = bus;
        };
      }
  );

  pciDevice = domain: bus: slot: function: {
    domain = domain;
    bus = bus;
    slot = slot;
    function = function;
  };
}
