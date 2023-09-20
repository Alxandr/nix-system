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

  # options = {
  #   perSystem = mkPerSystemOption {
  #     _file = file;
  #     options.nixosTemplates = mkOption {
  #       type = types.lazyAttrsOf types.submoduleWith {
  #         modules = [{
  #           options.
  #         }];
  #       };
  #     };
  #   };
  # };

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

            setupPkg = (
              pkgs.callPackage ./packages/setup-host
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
              setup = setupPkg;
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
            setupPackages = lib.listToAttrs (builtins.map
              (cfg: {
                name = cfg.packages.setup.name;
                value = cfg.packages.setup;
              })
              systemConfigs);

            installPackages = {
              install = pkgs.callPackage ./packages/install {
                inherit setupPackages;
              };
            };

            packages = setupPackages // installPackages;
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

      # # config.flake.fff = disko.lib.diskoScript config.flake.diskoConfigurations.test inputs.nixpkgs.legacyPackages.x86_64-linux;
      # perSystem = { pkgs, ... }: {
      #   # packages.format-test = disko.lib.diskoScript config.flake.diskoConfigurations.test pkgs;
      #   packages = lib.mapAttrs'
      #     (name: config: {
      #       name = "setup-${name}";
      #       value = pkgs.callPackage ./packages/setup-host {
      #         inherit config name;
      #         disko = disko.lib;
      #       }; # disko.lib.diskoScript config pkgs;
      #     })
      #     config.flake.diskoConfigurations;
      # };
      # lib.mapAttrs
      #   (systemName: system:
      #     lib.mapAttrs'
      #       (templateName: template: {
      #         name = "setup-${templateName}";
      #         value = config.flake.nixosConfigurations."${templateName}-${systemName}".config;
      #       })
      #       system.nixosTemplates
      #   )
      #   config.allSystems;
      # let
      #   getTemplatesList = systemName: system: lib.mapAttrsToList
      #     (templateName: template: {
      #       name = "setup-${templateName}";
      #       value = template;
      #     })
      #     system.nixosTemplates;

      #   templatesListList = lib.mapAttrsToList getTemplatesList config.allSystems;
      #   templatesList = lib.flatten templatesListList;
      # in
      # lib.listToAttrs templatesList;
    };
}
