{ lib, flake-parts-lib, config, inputs, nixosModules, ... }:
with lib;
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (config.flake) path;
in
{
  options = {
    nixosConfigurationsExtraSpecialArgs = mkOption {
      type = types.lazyAttrsOf types.raw;
      description = ''
        Extra arguments to pass to `lib.nixosSystem` when instantiating
        the `nixosConfigurations` option.
      '';
      default = { };
    };

    perSystem = mkPerSystemOption {
      options.nixosConfigurations = mkOption {
        type = types.lazyAttrsOf types.deferredModule;
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
    flake.nixosConfigurations =
      let
        getTemplatesList = systemName: system: lib.mapAttrsToList
          (templateName: template: rec {
            name = "${templateName}-${systemName}";
            value = inputs.nixpkgs.lib.nixosSystem {
              system = systemName;
              modules = [
                {
                  _module.args = { system = systemName; };
                  meta.flake.path = path;
                  meta.flake.configName = name;
                }
                nixosModules.flake-meta
                template
              ];
              specialArgs = config.nixosConfigurationsExtraSpecialArgs;
            };
          })
          system.nixosConfigurations;

        templatesListList = lib.mapAttrsToList getTemplatesList config.allSystems;
        templatesList = lib.flatten templatesListList;
      in
      lib.listToAttrs templatesList;
  };
}
