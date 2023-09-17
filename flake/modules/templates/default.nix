{ lib, flake-parts-lib, config, inputs, ... }:
let
  inherit (lib) mkOption types literalExpression;
  inherit (flake-parts-lib) mkPerSystemOption;

  file = ./nixos-templates.nix;
in
{
  _file = file;

  options = {
    perSystem = mkPerSystemOption {
      _file = file;
      options.nixosTemplates = mkOption {
        type = types.lazyAttrsOf types.unspecified;
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
          (templateName: template: {
            name = "${templateName}-${systemName}";
            value = inputs.nixpkgs.lib.nixosSystem {
              system = systemName;
              modules = [ template ];
            };
          })
          system.nixosTemplates;

        templatesListList = lib.mapAttrsToList getTemplatesList config.allSystems;
        templatesList = lib.flatten templatesListList;
      in
      lib.listToAttrs templatesList;
  };
}
