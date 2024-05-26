{ lib, flake-parts-lib, config, inputs, nixosModules, ... }:
with lib;
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (config.flake) path;
in {
  options = {
    nixosConfigurationsExtraSpecialArgs = mkOption {
      type = types.lazyAttrsOf types.raw;
      description = ''
        Extra arguments to pass to `lib.nixosSystem` when instantiating
        the `nixosConfigurations` option.
      '';
      default = { };
    };

    allNixosConfigurations = mkOption {
      type = types.deferredModule;
      description = ''
        Module applied to all NixOS configurations.
      '';
      default = { };
    };

    perSystem = mkPerSystemOption {
      options.nixosConfigurations = mkOption {
        type = types.lazyAttrsOf (types.submodule {
          options = {
            config = mkOption {
              type = types.deferredModule;
              description = ''
                The NixOS configuration for this system.
              '';
            };

            unstable = mkOption {
              type = types.bool;
              description = ''
                Whether to use the unstable version of NixOS.
              '';
              default = false;
            };
          };
        });
        description = ''
          Instantiated NixOS configurations, but without the "system" configured.
          This is really just nixos modules that are replicated per "system".
          Do not call `lib.nixosSystem`.
        '';
        default = { };
      };
    };
  };

  config = {
    flake.nixosConfigurations = let
      getTemplatesList = systemName: system:
        lib.mapAttrsToList (templateName: template:
          let
            nixpkgs = if template.unstable then
              inputs.nixpkgs-unstable
            else
              inputs.nixpkgs;
            home-manager = if template.unstable then
              inputs.home-manager-unstable
            else
              inputs.home-manager;
          in rec {
            name = "${templateName}-${systemName}";
            value = nixpkgs.lib.nixosSystem {
              system = systemName;
              modules = [
                {
                  _module.args = { system = systemName; };
                  meta.flake.path = path;
                  meta.flake.configName = name;
                  meta.templateName = templateName;
                }
                nixosModules.flake-meta
                nixosModules.nixos-meta
                config.allNixosConfigurations
                home-manager.nixosModules.home-manager
                template.config
              ];
              specialArgs = config.nixosConfigurationsExtraSpecialArgs;
            };
          }) system.nixosConfigurations;

      templatesListList = lib.mapAttrsToList getTemplatesList config.allSystems;
      templatesList = lib.flatten templatesListList;
    in lib.listToAttrs templatesList;
  };
}
