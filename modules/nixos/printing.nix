{ ... }:

{
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "HL-1212w";
        location = "Home";
        deviceUri = "ipp://192.168.10.66/printers/brother";
        model = "everywhere";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "HL-1212w";
  };
}
