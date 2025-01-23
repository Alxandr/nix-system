{ lib, ... }:

let
  workloads-lib = import ../lib.nix { inherit lib; };
in
{
  _module.args = { inherit workloads-lib; };
}
