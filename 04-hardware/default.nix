{
  flake-parts-lib,
  inputs,
  ...
}:
{
  flake.nixosModules =
    let
      inherit (flake-parts-lib) importApply;
      importModule = path: args: (importApply path args) // { _class = "nixos"; };
      importHardwareModule = path: importModule path {
        nixos-hardware = inputs.nixos-hardware.nixosModules;
      };

    in {
      minisforum-ms-s1-max = importHardwareModule ./nixos-modules/minisforum/ms-s1-max.nix;
    } // inputs.nixos-hardware.nixosModules;
}
