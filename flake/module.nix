{ lib, flake-parts-lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in
{
  imports = [
    ./disks
    ./users
    ./modules/templates
    ./modules/installer
  ];

  options.flake = mkSubmoduleOptions {
    lib = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
    };
  };
}
