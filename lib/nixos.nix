{ lib, disko }:
{ name
, system
, users
, hardware
, neovim
, diskoConfiguration
, keyFiles
, interactive
}:

let
  users-module = {
    users.groups = lib.mapAttrs (name: cfg: { }) users;
    users.users = lib.mapAttrs
      (name: cfg: {
        isNormalUser = true;
        extraGroups = [ name "users" ] ++ cfg.groups;
        openssh.authorizedKeys.keys = cfg.authorized-keys;
      })
      users;
  };

  disk-layout-modules = [
    disko
    diskoConfiguration
  ];

  disk-encryption-modules =
    if interactive
    then [ ]
    else
      let
        key-file-paths = lib.attrValues keyFiles;
        key-set = lib.genAttrs key-file-paths (f: f);
      in
      [{
        boot.initrd.secrets = key-set;
      }];

  modules = [ hardware ]
    ++ disk-layout-modules
    ++ disk-encryption-modules
    ++ [ ./nixos/common.nix users-module ]
    ++ [ ({ pkgs, lib, ... }: neovim { inherit pkgs lib system; }) ];
in

lib.nixosSystem {
  inherit system modules;
}
