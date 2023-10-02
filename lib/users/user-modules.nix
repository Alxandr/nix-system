{ lib, ... }:
with lib;
{
  options = {
    user = mkOption {
      # TODO: Type
      type = types.raw;
    };

    home = mkOption {
      type = types.deferredModule;
    };
  };

  config = {
    home = { ... }: {
      home.stateVersion = "23.05";
    };
  };
}
