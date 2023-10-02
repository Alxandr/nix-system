# flake module
{ lib, flake-parts-lib, inputs, ... }:
let
  inherit (inputs) disko;
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;

in
{
  options.flake = mkSubmoduleOptions {
    diskoConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
    };
  };

  config.flake.nixosModules.disko = disko.nixosModules.disko;
}
