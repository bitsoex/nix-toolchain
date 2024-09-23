{ pkgs, ... }:
let
  lib = pkgs.lib;
in
{
  options = {
    buildInputs = lib.mkOption { type = lib.types.listOf lib.types.package; };

    shellHook = lib.mkOption { type = lib.types.lines; };

  };
}
