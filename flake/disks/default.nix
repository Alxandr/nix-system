# flake module
{ lib, flake-parts-lib, inputs, config, ... }:
let
  inherit (lib) mkOption types literalExpression;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in
{
  imports = [
    ./keys.nix
  ];
}
