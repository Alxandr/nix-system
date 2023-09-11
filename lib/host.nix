{ lib
, flake
, disko
, neovim
, home-manager
, supportedSystems
}:

let
  mkDisks = import ./disks.nix { inherit lib; };
  mkNixos = import ./nixos.nix { inherit lib disko flake; };
  mkUsers = import ./users.nix {
    inherit lib;
    inherit (home-manager.lib) homeManagerConfiguration;
  };
in
rec {
  mkHost = name: dir:
    let
      disks = mkDisks (import "${dir}/disks.nix");
      systems =
        if builtins.pathExists "${dir}/systems.nix"
        then import "${dir}/systems.nix" { inherit lib; }
        else supportedSystems;

      users = mkUsers {
        alxandr = ../users/alxandr;
      };

      hardware = import "${dir}/hardware.nix";

      nixosConfigurations = builtins.listToAttrs (builtins.map
        (system: {
          name = "${name}-${system}";
          value = mkNixos {
            inherit system users name hardware neovim;
            inherit (disks) diskoConfiguration keyFiles interactive;
            inherit (home-manager.nixosModules) home-manager;
          };
        })
        systems);

      supportsSystem = system: builtins.elem system systems;
    in
    {
      inherit systems users nixosConfigurations supportsSystem name;
      inherit (disks) diskoConfiguration keyFiles interactive;
    };

  mkHosts = hosts: builtins.mapAttrs mkHost hosts;
}
