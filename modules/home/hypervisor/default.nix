{
  pkgs,
  config,
  lib,
  host,
  ...
}:

let
  cfg = config.custom.hypervisor.client;

  nixgl = import ../../../utils/nixgl.nix {
    inherit pkgs lib;
  };

  user = "ametis70";
  hostname = "hypervisor.lan";

  hypervisor-virt-manager = pkgs.writeShellScriptBin "hvm" ''
    trap 'ssh -S /tmp/ssh-hvm-socket -O exit ${user}@${hostname}' EXIT
    ssh -f -N -M -S /tmp/ssh-hvm-socket ${user}@${hostname}
    ${pkgs.virt-manager}/bin/virt-manager -c 'qemu+ssh://${user}@${hostname}/system'
  '';
in
{
  options.custom.hypervisor.client = {
    enable = lib.mkEnableOption "Enable hypervisor client";
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      if (host.system == "x86_64-linux" && !host.nixos) then
        [ (nixgl.wrapMesa hypervisor-virt-manager) ]
      else
        [ hypervisor-virt-manager ];
  };
}
