{
  lib,
  ...
}:

with lib;

{
  options.trusted = mkOption {
    type = types.bool;
    default = false;
  };
}
