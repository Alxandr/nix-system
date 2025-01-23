{ }:
{ lib, config, ... }:

let
  inherit (lib) mkOption types;
in
{
  options.flake.path = mkOption {
    type = types.nonEmptyStr;
  };
}
