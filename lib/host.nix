{ lib }:

let mkDisks = import ./disks.nix { inherit lib; };

in
rec {
  mkHost = dir:
    let
      disks = mkDisks (import "${dir}/disks.nix");
    in
    { inherit (disks) diskoConfiguration keyFiles interactive; };

  mkHosts = hosts: builtins.mapAttrs (name: dir: mkHost dir) hosts;
}
