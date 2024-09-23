{
  config,
  pkgs,
  cloudflareCA,
  ...
}:

let
  cfg = config.java;
  lib = pkgs.lib;

in
{
  options = {
    java = {
      enable = lib.mkEnableOption "Java";
      version = lib.mkOption {
        type = lib.types.enum [
          "17"
          "19"
          "21"
          "22"
        ];
        default = "21";
      };

      gradle = {
        enable = lib.mkEnableOption "Gradle";
      };
    };
  };

  config =
    let
      jdkPackages = {
        "17" = pkgs.jdk17;
        "19" = pkgs.jdk19;
        "21" = pkgs.jdk21;
        "22" = pkgs.jdk22;
      };

      selectedJdk = jdkPackages.${cfg.version};

      customJdk = selectedJdk.overrideAttrs (oldAttrs: {
        postFixup =
          oldAttrs.postFixup
          + ''
            $out/bin/keytool -importcert -file ${cloudflareCA} \
              -alias cloudflare-ca -cacerts \
              -storepass changeit -noprompt
          '';
      });

      gradle = pkgs.gradle.override { java = customJdk; };
    in
    lib.mkIf cfg.enable {
      buildInputs = [ customJdk ] ++ lib.optional cfg.gradle.enable gradle;

      shellHook = ''
        export JAVA_HOME=${customJdk}
        ${lib.optionalString cfg.gradle.enable "export GRADLE_HOME=${gradle}"}
      '';
    };
}
