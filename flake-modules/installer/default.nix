{ lib, flake-parts-lib, config, inputs, ... }:
let
  inherit (inputs) disko;
  inherit (lib) mkOption types literalExpression;
  inherit (flake-parts-lib) mkPerSystemOption;

in {
  imports = [ ../flake-path.nix ];

  config = let
    flakePath = config.flake.path;
    systemConfigurations = lib.mapAttrsToList (cfgName: osCfg:
      let
        inherit (osCfg) pkgs;
        inherit (pkgs) system;

        name = lib.removeSuffix "-${system}" cfgName;
        flake = {
          path = flakePath;
          name = cfgName;
        };

        installPkg = (pkgs.callPackage ./packages/install-system {
          inherit name flake;
          disko = disko.lib;
          nixosConfiguration = osCfg.config;
        }) // {
          setupMeta = { inherit name; };
        };

        packages = { install = installPkg; };
      in { inherit name system flake packages; })
      config.flake.nixosConfigurations;

    bySystem = lib.groupBy (c: c.system) systemConfigurations;
    packages = lib.mapAttrs (system: systemConfigs:
      let
        inherit (inputs.nixpkgs.legacyPackages.${system}) pkgs;
        installSpecificSystemPackages = lib.listToAttrs (builtins.map (cfg: {
          name = cfg.packages.install.agnostic-name;
          value = cfg.packages.install;
        }) systemConfigs);

        installPackages = {
          install = pkgs.callPackage ./packages/install-any {
            installPackages = installSpecificSystemPackages;
          };
        };

        packages = installSpecificSystemPackages // installPackages;
      in packages) bySystem;

    apps = lib.mapAttrs (name: systemPackages:
      lib.mapAttrs (name: package: { program = package; }) systemPackages)
      packages;
  in {
    flake.packages = packages;
    flake.apps = apps;
  };
}
