{ pkgs, config, ... }:
let
  cfg = config.redis;
  lib = pkgs.lib;
in
{
  options = {
    redis.enable = lib.mkEnableOption "Redis";
  };
  config = lib.mkIf cfg.enable {
    buildInputs = [ pkgs.redis ];

    processes.redis = {
      command = "${pkgs.redis}/bin/redis-server";
    };
  };
}
