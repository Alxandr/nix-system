{ ... }: {
  imports = [
    ./module.nix
  ];

  flake.flakeModules = {
    default = import ./module.nix;
    disko = import ./vendor/disko;
    disks = import ./disks;
  };
}
