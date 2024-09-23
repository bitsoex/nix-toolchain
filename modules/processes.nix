{ pkgs, config, ... }:
let
  lib = pkgs.lib;
  cfg = config.processes;
in
{
  options = {
    processes = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            command = lib.mkOption { type = lib.types.str; };
            cwd = lib.mkOption {
              type = lib.types.str;
              default = ".";
            };
            environment = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
              default = null;
            };
            depends_on = lib.mkOption {
              type = lib.types.nullOr (lib.types.listOf lib.types.str);
              default = null;
            };
          };
        }
      );
      default = { };
      description = "Process configuration matching the format from process-compose";
    };
  };

}
