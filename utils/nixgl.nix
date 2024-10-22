{ pkgs, lib, ... }:
let

  makeNixGLWrapper =
    bin: pkg:
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
        wrapped_bin=$out/bin/$(basename $bin)
        echo "exec ${bin} $bin \$@" > $wrapped_bin
        chmod +x $wrapped_bin
      done
    '';

  wrapMesa = makeNixGLWrapper "${lib.getExe pkgs.nixgl.nixGLIntel}";
  wrapVulkan = makeNixGLWrapper "${lib.getExe pkgs.nixgl.nixVulkanIntel}";
  wrapVulkanMesa = makeNixGLWrapper "${lib.getExe pkgs.nixgl.nixGLIntel} ${lib.getExe pkgs.nixgl.nixVulkanIntel}";

in
{
  wrapMesa = wrapMesa;
  wrapVulkan = wrapVulkan;
  wrapVulkanMesa = wrapVulkanMesa;
}
