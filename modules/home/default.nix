{ lib, ... }:

# Aggregator: auto-discovers every module directory (one that contains a
# default.nix) and imports it, so all `custom.*` options are always available.
# Modules must be option-guarded (default off, except base ones) — importing
# this file must not change behaviour until a host sets `custom.<name>.enable`.
let
  dirs = lib.filterAttrs (
    name: type: type == "directory" && builtins.pathExists (./. + "/${name}/default.nix")
  ) (builtins.readDir ./.);
in
{
  imports = lib.mapAttrsToList (name: _: ./. + "/${name}") dirs;
}
