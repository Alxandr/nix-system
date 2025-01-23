{ flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) importApply;
  importModule =
    cls: path: args:
    (importApply path args) // { _class = cls; };
  importNixosModule = importModule "nixos";
  importFlakeModule = importModule "flake";

in
{
  imports = [
  ];

  config.flake = {
    flakeModules = {
      user-manager = importFlakeModule ./flake-modules/user-manager.nix { inherit flake-parts-lib; };
    };

    nixosModules = {
      user-manager = importNixosModule ./nixos-modules/user-manager.nix {
      };
    };
  };
}
