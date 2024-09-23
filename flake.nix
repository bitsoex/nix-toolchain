{
  description = "A Java/Gradle Project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";

    cloudflare-ca = {
      url = "https://developers.cloudflare.com/cloudflare-one/static/documentation/connections/Cloudflare_CA.pem";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      cloudflare-ca,
      ...
    }:
    {
      lib = {
        mkProject =
          config@{ ... }:
          (flake-utils.lib.eachDefaultSystem (
            system:
            let
              pkgs = import nixpkgs { inherit system; };
              shell = pkgs.lib.evalModules {
                modules = [
                  config
                  ./modules/git.nix
                  ./modules/processes.nix
                  ./modules/shell.nix
                  ./modules/java.nix
                  ./modules/redis.nix
                ];
                specialArgs = {
                  inherit pkgs;
                  cloudflareCA = cloudflare-ca;
                };
              };

              processConfig = {
                processes = shell.config.processes;
              };

              processesYaml = pkgs.runCommand "processes.yaml" { buildInputs = [ pkgs.yq-go ]; } ''
                echo '${builtins.toJSON processConfig}' | yq eval -P - > $out
              '';

              processComposeUp = pkgs.writeShellScriptBin "run-process-compose" ''
                ${pkgs.process-compose}/bin/process-compose up -f ${processesYaml}
              '';

            in
            {
              devShells.default = pkgs.mkShell {
                buildInputs = shell.config.buildInputs ++ [
                  pkgs.process-compose
                  processComposeUp
                ];
                shellHook = shell.config.shellHook;
              };

              apps.default =
                (pkgs.lib.mkIf (shell.config.processes != { }) {
                  type = "app";
                  program = "${processComposeUp}/bin/run-process-compose";
                }).content;
            }
          ));
      };
    };
}
