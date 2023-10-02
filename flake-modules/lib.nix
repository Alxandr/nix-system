{ lib, flake-parts-lib, ... }:
with lib;
let
  inherit (flake-parts-lib) mkSubmoduleOptions;
in
{
  options.flake = mkSubmoduleOptions {
    lib = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
    };
  };
}
