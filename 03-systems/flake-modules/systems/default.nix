{ inputs, flake-parts-lib }:
{ lib, config, ... }:

with lib;

let
  inherit (flake-parts-lib) importApply;
  inherit (inputs)
    base
    users
    workloads
    disko
    nixpkgs
    nixpkgs-unstable
    home-manager
    home-manager-unstable
    stylix
    stylix-unstable
    ;

  cfg = config.systemConfigurations;
  systemType = types.submodule {
    options.system = mkOption {
      type = types.enum config.systems;
      default = cfg.defaults.system;
    };

    options.unstable = mkOption {
      type = types.bool;
      default = cfg.defaults.unstable;
    };

    options.isoImage.enable = mkOption {
      type = types.bool;
      default = cfg.defaults.isoImage.enable;
      description = ''
        Enable ISO image generation.
      '';
    };

    options.extraSpecialArgs = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression "{ inherit emacs-overlay; }";
      description = ''
        Extra `specialArgs` passed to all system configurations. This
        option can be used to pass additional arguments to all modules.
      '';
    };

    options.hardware = mkOption {
      type = types.deferredModule;
      description = ''
        Hardware configuration.
      '';
    };

    options.drives = mkOption {
      type = types.deferredModule;
      description = ''
        Hardware configuration.
      '';
    };

    options.users = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
    };

    options.configuration = mkOption {
      type = types.deferredModule;
      example = literalExpression "[{ environment.systemPackages = [ nixpkgs-fmt ]; }]";
      description = ''
        Modules added to all system configurations.
      '';
    };
  };
in

{
  imports = [
    base.flakeModules.flake-path
  ];

  options = {
    systemConfigurations = {
      extraSpecialArgs = mkOption {
        type = types.attrs;
        default = { };
        example = literalExpression "{ inherit emacs-overlay; }";
        description = ''
          Extra `specialArgs` passed to all system configurations. This
          option can be used to pass additional arguments to all modules.
        '';
      };

      sharedModules = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
        example = literalExpression "[{ environment.systemPackages = [ nixpkgs-fmt ]; }]";
        description = ''
          Extra modules added to all system configurations.
        '';
      };

      defaults.system = mkOption {
        type = types.enum config.systems;
        default = if config.systems == [ ] then null else builtins.head config.systems;
      };

      defaults.unstable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Use unstable Nixpkgs and Home-Manager.
        '';
      };

      defaults.isoImage.enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable ISO image generation.
        '';
      };

      systems = mkOption {
        type = types.lazyAttrsOf systemType;
        default = { };
        description = ''
          System configurations.
        '';
      };
    };
  };

  config.flake.nixosConfigurations = flip mapAttrs config.systemConfigurations.systems (
    name: systemConfiguration:
    let
      m =
        if !systemConfiguration.unstable then
          {
            inherit nixpkgs home-manager stylix;
          }
        else
          {
            nixpkgs = nixpkgs-unstable;
            home-manager = home-manager-unstable;
            stylix = stylix-unstable;
          };
    in
    m.nixpkgs.lib.nixosSystem {
      specialArgs = config.systemConfigurations.extraSpecialArgs // systemConfiguration.extraSpecialArgs;
      modules =
        [
          # Set the system platform using the new approach
          { nixpkgs.hostPlatform = systemConfiguration.system; }

          # common modules
          m.home-manager.nixosModules.home-manager
          m.stylix.nixosModules.stylix
          disko.nixosModules.disko
          users.nixosModules.user-manager
          workloads.nixosModules.workloads
          workloads.nixosModules.defaults
          (importApply ./modules/flake-meta.nix {
            inherit name;
            inherit (config.flake) path;
          })
          (importApply ./modules/users.nix {
            inherit (systemConfiguration) users;
          })

          # per-system modules
          systemConfiguration.hardware
          systemConfiguration.drives
          systemConfiguration.configuration
        ]
        ++ lib.optional systemConfiguration.isoImage.enable (importApply ./modules/iso-image.nix { })
        ++ config.systemConfigurations.sharedModules;
    }
  );

  # config.flake.packages =
  #   let
  #     images = flip mapAttrs config.systemConfigurations.systems (
  #       name: systemConfiguration:
  #       let
  #         inherit (systemConfiguration) system;
  #         isoPkg = config.flake.nixosConfigurations.${name}.config.system.build.isoImage;
  #         isoPath = "${isoPkg}/iso/${isoPkg.isoName}";
  #       in
  #       {
  #         inherit system name;
  #         package =
  #           config.flake.nixosConfigurations.${name}.pkgs.runCommand "iso-${name}"
  #             {
  #               iso = isoPath;
  #             }
  #             ''
  #               mkdir $out
  #               ln -s $iso $out/${name}.iso
  #             '';
  #       }
  #     );

  #   in
  #   lib.attrsets.foldlAttrs (
  #     acc: name: value:
  #     acc
  #     // {
  #       ${value.system} = (acc.${value.system} or { }) // {
  #         "iso-${value.name}" = value.package;
  #       };
  #     }
  #   ) { } images;
}
