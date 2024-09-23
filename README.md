# nix-toolchain

Experiments using Nix to manage project toolchains.

## Installing Nix

This project uses Nix and Nix Flakes to manage toolchains. If you don't have Nix installed, you can install it using the [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer):

    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

## Usage

In a project that needs a toolchain, add `flake.nix`

```nix
{
  description = "A Java/Gradle Project";

  inputs = {
    bitso.url = "github:bitsoex/nix-toolchain";
  };

  outputs =
    { bitso, ... }:
    bitso.lib.mkProject {
      java = {
        enable = true;
        version = "17";
        gradle.enable = true;
      };
      redis.enable = true;
    };
}
```