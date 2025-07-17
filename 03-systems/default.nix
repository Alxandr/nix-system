{
  flake-parts-lib,
  inputs,
  ...
}:
{
  flake.flakeModules =
    let
      inherit (flake-parts-lib) importApply;
      importModule = path: args: (importApply path args) // { _class = "flake"; };

    in
    {
      systems = importModule ./flake-modules/systems { inherit inputs flake-parts-lib; };
      install = importModule ./flake-modules/install { inherit inputs flake-parts-lib; };
    };
}
