{ flake-parts-lib }:
{
  lib,
  config,
  options,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;

in
# cfg = config.usersModules;
# userType = options.users.users.type.nestedTypes.elemType;
#
# userModule = types.submoduleWith {
#   description = "User module";
#   class = "user";
#   specialArgs = {
#     inherit lib;
#     osConfig = config;
#   } // cfg.extraSpecialArgs;
#
#   modules = [
#     {
#       options.user = mkOption {
#         type = userType;
#         default = { };
#       };
#     }
#   ] ++ cfg.sharedModules;
# };
{
  # options.user = mkOption {
  #   type = types.lazyAttrsOf types.deferredModule;
  #   default = { };
  # };

  options.flake = mkSubmoduleOptions {
    userConfigurations = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
    };

    userModules = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
    };
  };
}
