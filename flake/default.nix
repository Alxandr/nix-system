{ ... }: {
  imports = [
    ./module.nix
  ];

  flake.flakeModules = {
    default = ./module.nix;
    disko = ./vendor/disko;
    home-manager = ./vendor/home-manager;
    disks = ./disks;
    users = ./users;
  };
}
