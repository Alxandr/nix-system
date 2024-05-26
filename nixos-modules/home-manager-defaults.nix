{ nixosModules, ... }:
{ ... }: {
  imports = [ nixosModules.home-manager ];

  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
  };
}
