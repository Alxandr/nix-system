# flake module
{ flake-parts-lib }:
{ lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;

in
{
  options.flake = mkSubmoduleOptions {
    diskoConfigurations = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
    };
  };
}
