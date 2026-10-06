{ lib, ... }:

{
  imports = [ ./kitty ];

  options.custom.programs.terminal = {
    enable = lib.mkEnableOption "Enable default terminal";
  };
}
