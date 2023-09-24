{ ... }: {
  config.flake.nixosModules = {
    virtualbox-guest = ./modules/virtualbox-guest;
  };
}
