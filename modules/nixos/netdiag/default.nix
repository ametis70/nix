{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.custom.netdiag;
in
{
  options.custom.netdiag.enable = lib.mkEnableOption "network/hardware diagnostics tools (dmidecode, iperf, tcpdump, nmap, likwid)";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dmidecode
      likwid
      iperf
      tcpdump
      nmap
    ];
  };
}
