let
  host = import ./host.nix;
in
{
  inherit (host) mkHost mkHosts;
}
