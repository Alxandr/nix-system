{ lib }:

let
  host = import ./host.nix { inherit lib; };
in
{
  inherit (host) mkHost mkHosts;
}
