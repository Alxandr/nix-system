{ lib }: config:

let
  interactive = config.interactive or true;

  keyFiles = {
    root = "/etc/disk-encryption-keys/root.key";
  };

  optKey = name:
    if interactive
    then { }
    else { keyFile = keyFiles.${name}; };

  rootCfg = config.root // (optKey "root");

  root = import ./disks/root.nix rootCfg;

  diskoConfiguration = {
    disko.devices.disk = {
      root = root.disk;
    };
  };

in
{
  inherit diskoConfiguration keyFiles interactive;
}
