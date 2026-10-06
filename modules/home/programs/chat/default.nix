{ lib, ... }:

{
  imports = [
    ./discord
    ./telegram
  ];

  options.custom.programs.chat = {
    enable = lib.mkEnableOption "Enable chat programs";
  };
}
