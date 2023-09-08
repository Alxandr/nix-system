let mkDisks = import ./disks.nix;

in
rec {
  mkHost = dir:
    let
      diskoConfiguration = mkDisks (import "${dir}/disks.nix");
    in
    { inherit diskoConfiguration; };

  mkHosts = hosts: builtins.mapAttrs (name: dir: mkHost dir) hosts;
}
