{ flake-parts-lib, ... }:
{ lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;

in
{
  options.flake = mkSubmoduleOptions {
    homeConfigurations = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
    };

    homeModules = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
    };
  };
}
