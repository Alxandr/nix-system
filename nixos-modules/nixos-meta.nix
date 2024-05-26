{ ... }:
{ lib, config, ... }:
with lib; {
  options.meta.templateName = mkOption { type = types.str; };

  config = { networking.hostName = mkDefault config.meta.templateName; };
}
