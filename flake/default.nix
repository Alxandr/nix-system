{ ... }: {
  imports = [
    ./module.nix
  ];

  flake.flakeModules = {
    default = import ./module.nix;
    disko = import ./vendor/disko;
    home-manager = import ./vendor/home-manager;
    disks = import ./disks;
    users = import ./users;
  };
}
