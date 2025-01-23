{ }:
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.user-manager;

  umModule = types.submoduleWith {
    description = "User Manager module";
    class = "userManager";
    specialArgs = {
      inherit lib;
      osConfig = config;
      modulesPath = builtins.toString ../modules;
    } // cfg.extraSpecialArgs;
    modules = [
      (
        { name, ... }:
        {
          imports = import ../modules/modules.nix {
            inherit pkgs lib;
          };
        }
      )
    ] ++ cfg.sharedModules;
  };

in
{
  options.user-manager = {
    extraSpecialArgs = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression "{ inherit emacs-overlay; }";
      description = ''
        Extra `specialArgs` passed to User Manager. This
        option can be used to pass additional arguments to all modules.
      '';
    };

    sharedModules = mkOption {
      type = types.listOf types.deferredModule;
      default = [ ];
      example = literalExpression "[{ user.packages = [ nixpkgs-fmt ]; }]";
      description = ''
        Extra modules added to all users.
      '';
    };

    users = mkOption {
      type = types.attrsOf umModule;
      default = { };
      # Prevent the entire submodule being included in the documentation.
      visible = "shallow";
      description = ''
        Per-user User Manager configuration.
      '';
    };

    # __tmp = mkOption {
    #   type = types.raw;
    #   default = options.users.users.type.nestedTypes.elemType;
    # };
  };

  config = mkMerge [
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }
    (mkIf (cfg.users != { }) {
      warnings = flatten (
        flip mapAttrsToList cfg.users (
          user: config: flip map config.warnings (warning: "${user} profile: ${warning}")
        )
      );

      assertions = flatten (
        flip mapAttrsToList cfg.users (
          user: config:
          flip map config.assertions (assertion: {
            inherit (assertion) assertion;
            message = "${user} profile: ${assertion.message}";
          })
        )
      );

      users.users = flip mapAttrs cfg.users (user: config: config.user);
      users.groups = flip mapAttrs cfg.users (user: config: config.group);
      home-manager.users = flip mapAttrs cfg.users (user: config: config.home);

      nix.settings.trusted-users = flatten (
        flip mapAttrsToList cfg.users (user: config: if config.trusted then [ user ] else [ ])
      );

      programs._1password-gui.enable = foldl lib.or false (
        flip mapAttrsToList cfg.users (user: config: config.programs._1password.enable)
      );
      programs._1password-gui.polkitPolicyOwners = flatten (
        flip mapAttrsToList cfg.users (
          user: config: if config.programs._1password.enable then [ user ] else [ ]
        )
      );
    })
  ];
}
