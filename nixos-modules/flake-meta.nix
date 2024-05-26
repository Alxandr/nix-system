{ ... }:
{ lib, config, ... }:
with lib; {
  options.meta.flake = mkOption {
    type = types.submodule ({ config, ... }: {
      options.path = mkOption { type = types.str; };

      options.configName = mkOption { type = types.str; };

      options.configPath = mkOption {
        type = types.str;
        default = "${config.path}#${config.configName}";
      };
    });
    default = { };
  };

  config = {
    system.autoUpgrade.flake = mkDefault config.meta.flake.configPath;
  };
}
