{ lib, disko, flake }:
{ name
, system
, users
, hardware
, neovim
, home-manager
, diskoConfiguration
, keyFiles
, interactive
}:

let
  users-module = {
    users.groups = lib.mapAttrs (name: cfg: { }) users;
    users.users = lib.mapAttrs (name: cfg: cfg.config) users;
  };

  auto-upgrade-module = {
    system.autoUpgrade = {
      enable = lib.mkDefault true;
      flake = "${flake}#${name}-${system}";
      allowReboot = lib.mkDefault true;
    };
  };

  hostname-module = {
    networking.hostName = lib.mkDefault name;
  };

  home-manager-config-module = { pkgs, ... }: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    home-manager.users = lib.mapAttrs (name: cfg: cfg.home-manager pkgs) users;
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

  modules = [ hardware auto-upgrade-module ]
    ++ disk-layout-modules
    ++ disk-encryption-modules
    ++ [ ./nixos/common.nix users-module hostname-module ]
    ++ [ ({ pkgs, lib, ... }: neovim { inherit pkgs lib system; }) ]
    ++ [ home-manager home-manager-config-module ];
in

lib.nixosSystem {
  inherit system modules;
}
