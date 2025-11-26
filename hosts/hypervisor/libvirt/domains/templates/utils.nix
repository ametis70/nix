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

  # mkDisks handles inputs such as:"foo.qcow2" (stored under /var/lib/libvirt/images),
  # { name = "/abs/path.qcow2"; target = "vdb"; } for custom target names,
  # { type = "block"; name = "/dev/mapper/vg/lv"; } for block devices,
  # { source = { file = "/somewhere/disk.img"; }; driver = { type = "raw"; }; }
  # to pass through bespoke driver/source settings.
  # driver can also be a string, e.g. { name = "foo.qcow2"; driver = "raw"; }.
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
      diskType = if isSet && (builtins.hasAttr "type" disk) then disk.type else "file";
      defaultDriver = {
        name = "qemu";
        type = "qcow2";
        cache = "none";
        discard = "unmap";
      };
      driverAttr = if isSet && (builtins.hasAttr "driver" disk) then disk.driver else null;
      driver =
        if driverAttr == null then
          defaultDriver
        else if builtins.isString driverAttr then
          defaultDriver // { type = driverAttr; }
        else if builtins.isAttrs driverAttr then
          driverAttr
        else
          throw "Driver must be string or attribute set";
      source =
        if isSet && (builtins.hasAttr "source" disk) then
          disk.source
        else
          let
            path = if (isAbsolute name) then name else "/var/lib/libvirt/images/${name}";
          in
          if diskType == "block" then { dev = path; } else { file = path; };
      target = if isSet && (builtins.hasAttr "target" disk) then disk.target else "vda";
      bus = if isSet && (builtins.hasAttr "bus" disk) then disk.bus else "virtio";
    in
    if !isStr && !isSet then
      throw "Disk is not string or set"
    else
      {
        type = diskType;
        device = "disk";
        driver = driver;
        source = source;
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
