{
  pkgs,
  lib,
  config,
  host,
  ...
}:

let
  cfg = config.custom.hvm;

  nixgl = import ../../../utils/nixgl.nix {
    inherit pkgs lib;
  };

  hypervisor-virt-manager = pkgs.writeShellScriptBin "hvm" ''
    trap 'ssh -S /tmp/ssh-hvm-socket -O exit ametis70@hypervisor.lan' EXIT
    ssh -f -N -M -S /tmp/ssh-hvm-socket ametis70@hypervisor.lan
    ${pkgs.virt-manager}/bin/virt-manager -c 'qemu+ssh://ametis70@hypervisor.lan/system'
  '';
in
{
  options.custom.hvm.enable = lib.mkEnableOption "hypervisor virt-manager launcher (hvm) + virt-manager";

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        virt-manager
      ]
      ++ (
        if (host.system == "x86_64-linux" && !host.nixos) then
          [ (nixgl.wrapMesa hypervisor-virt-manager) ]
        else
          [ hypervisor-virt-manager ]
      );
  };
}
