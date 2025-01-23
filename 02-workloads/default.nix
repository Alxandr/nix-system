{ inputs, ... }:

let
  lib = inputs.nixpkgs.lib;
  workloads-lib = import ./lib.nix { inherit lib; };

in
{
  config.flake = {
    lib = workloads-lib;

    nixosModules = {
      workloads = ./nixos-modules/workloads.nix;
      defaults = ./nixos-modules/defaults.nix;
    };
  };
}
