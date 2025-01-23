{
  lib,
  ...
}:

with lib;

{
  options.programs._1password = {
    enable = mkEnableOption "1password";
  };
}
