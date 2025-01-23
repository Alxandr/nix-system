{ flake-parts-lib, ... }:
{
  flake.flakeModules =
    let
      inherit (flake-parts-lib) importApply;
      importModule = path: args: (importApply path args) // { _class = "flake"; };

    in
    {
      flake-path = importModule ./flake-modules/flake-path.nix { };
      disko = importModule ./flake-modules/disko.nix { inherit flake-parts-lib; };
      home-manager = importModule ./flake-modules/home-manager.nix {
        inherit flake-parts-lib;
      };
    };
}
