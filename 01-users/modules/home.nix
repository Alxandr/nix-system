{
  lib,
  ...
}:

with lib;

{
  options.home = mkOption {
    type = types.deferredModule;
    default = { };
  };
}
