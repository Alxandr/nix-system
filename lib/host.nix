{ lib
, disko
, neovim
, supportedSystems
}:

let
  mkDisks = import ./disks.nix { inherit lib; };
  mkNixos = import ./nixos.nix { inherit lib disko; };
in
rec {
  mkHost = name: dir:
    let
      disks = mkDisks (import "${dir}/disks.nix");
      systems =
        if builtins.pathExists "${dir}/systems.nix"
        then import "${dir}/systems.nix" { inherit lib; }
        else supportedSystems;

      users = {
        alxandr = import ../users/alxandr.nix;
      };

      hardware = import "${dir}/hardware.nix";

      nixosConfigurations = builtins.listToAttrs (builtins.map
        (system: {
          name = "${name}-${system}";
          value = mkNixos {
            inherit system users name hardware neovim;
            inherit (disks) diskoConfiguration keyFiles interactive;
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
