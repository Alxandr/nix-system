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

            nixpkgs = mkOption {
              type = types.raw;
              description = ''
                The Nixpkgs to use for the NixOS configuration.
              '';
              default = inputs.nixpkgs;
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
          let nixpkgs = template.nixpkgs;
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
