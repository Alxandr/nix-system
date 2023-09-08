config:

let
  root = import ./disks/root.nix config.root;

in
{
  disko.devices.disks = {
    root = root.disk;
  };
}
