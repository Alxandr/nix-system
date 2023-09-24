# flake module
{ lib, flake-parts-lib, inputs, ... }:
let
  inherit (inputs) home-manager;
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;

in
{
  options.flake = mkSubmoduleOptions {
    homeConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
    };
  };

  config.flake.nixosModules.home-manager = home-manager.nixosModules.home-manager;
}
