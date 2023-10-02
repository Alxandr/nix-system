{ lib, ... }:
let
  importModule = path: lib.setDefaultModuleLocation path (import path);
in
{
  flake.diskoConfigurations = {
    root-btrfs = importModule ./root-btrfs.nix;
  };
}
