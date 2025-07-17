{
  inputs,
  flake-parts-lib,
}:
{ lib, config, ... }:

let
  inherit (inputs) nixpkgs-unstable;
  inherit (config.flake) nixosConfigurations;

  count =
    nixosConfigurations
    |> lib.attrsets.foldlAttrs (
      acc: name: cfg:
      acc + 1
    ) 0;

  isSingle = count <= 1;

  bySystem =
    nixosConfigurations
    |> lib.attrsets.mapAttrsToList (
      name: cfg: {
        inherit name cfg;
        system = cfg.pkgs.system;
        install-pkg = cfg.pkgs.callPackage ./packages/install-system {
          inherit name;
          nixosConfiguration = cfg.config;
          flake = cfg.config.meta.flake;
        };
      }
    )
    |> lib.lists.groupBy' (acc: sys: acc // { "${sys.name}" = sys.install-pkg; }) { } (sys: sys.system);
in
{
  perSystem =
    { system, ... }:
    let
      pkgs = import nixpkgs-unstable { inherit system; };
      installers = bySystem.${system} or { };
      installerApps =
        installers
        |> lib.attrsets.mapAttrs' (
          name: pkg: {
            name = pkg.name;
            value = {
              type = "app";
              program = pkg;
              meta.description = "Install ${name} system";
            };
          }
        );

    in
    rec {
      packages =
        {
          install = pkgs.callPackage ./packages/install-any {
            inherit installers isSingle;
          };
        }
        // (
          installers
          |> lib.attrsets.mapAttrs' (
            name: value: {
              inherit (value) name;
              inherit value;
            }
          )
        );

      apps = {
        install = {
          type = "app";
          program = packages.install;
          meta.description = "Install a system";
        };
      } // installerApps;
    };
}
