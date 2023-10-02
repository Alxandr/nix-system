{ lib, flake-parts-lib, config, inputs, ... }:
let
  inherit (inputs) disko;
  inherit (lib) mkOption types literalExpression;
  inherit (flake-parts-lib) mkPerSystemOption;

  file = ./nixos-templates.nix;
in
{
  _file = file;

  options.flake.path = mkOption {
    type = types.str;
  };

  config =
    let
      flakePath = config.flake.path;
      configs = lib.mapAttrsToList
        (cfgName: config:
          let
            inherit (config) pkgs;
            inherit (pkgs) system;

            name = lib.removeSuffix "-${system}" cfgName;
            flake = {
              path = flakePath;
              name = cfgName;
            };

            installPkg = (
              pkgs.callPackage ./packages/install-host
                {
                  inherit name flake;
                  disko = disko.lib;
                  nixosConfiguration = config.config;
                }
            ) // {
              setupMeta = {
                inherit name;
              };
            };

            packages = {
              install = installPkg;
            };
          in
          {
            inherit name config system flake packages;
          })
        config.flake.nixosConfigurations;

      bySystem = lib.groupBy (c: c.system) configs;
      packages = lib.mapAttrs
        (system: systemConfigs:
          let
            inherit (inputs.nixpkgs.legacyPackages.${system}) pkgs;
            installSpecificSystemPackages = lib.listToAttrs (builtins.map
              (cfg: {
                name = cfg.packages.install.name;
                value = cfg.packages.install;
              })
              systemConfigs);

            installPackages = {
              install = pkgs.callPackage ./packages/install {
                installPackages = installSpecificSystemPackages;
              };
            };

            packages = installSpecificSystemPackages // installPackages;
          in
          packages)
        bySystem;

      apps = lib.mapAttrs
        (name: systemPackages: lib.mapAttrs
          (name: package: {
            program = package;
          })
          systemPackages)
        packages;
    in
    {
      flake.packages = packages;
      flake.apps = apps;
    };
}
