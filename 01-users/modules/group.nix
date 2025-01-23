{
  lib,
  name,
  osConfig,
  ...
}:

with lib;

let
  cfg = osConfig.users;

  groupOpts =
    { config, ... }:
    {
      options = {
        # name = mkOption {
        #   type = types.passwdEntry types.str;
        #   default = name;
        #   apply =
        #     x:
        #     assert (
        #       stringLength x < 32 || abort "Username '${x}' is longer than 31 characters which is not allowed!"
        #     );
        #     x;
        #   description = ''
        #     The name of the user account. If undefined, the name of the
        #     attribute set will be used.
        #   '';
        # };
      };

      config = mkMerge [
      ];
    };
in

{
  options.group = mkOption {
    type = types.submodule groupOpts;
    default = { };
  };

  # config.user.extraGroups = [ "users" ];

  # config.user = {
  #   isNormalUser = mkDefault true;
  #   name = mkDefault name;
  #   group = mkDefault config.user.name;
  # };
}
