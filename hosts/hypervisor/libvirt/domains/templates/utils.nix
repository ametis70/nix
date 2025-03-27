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

  pciDevice = domain: bus: slot: function: {
    domain = domain;
    bus = bus;
    slot = slot;
    function = function;
  };
}
