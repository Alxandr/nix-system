{ user, host, homeModules, ... }: {
  config.trusted = true;
  config.user.extraGroups = [ "wheel" "networkmanager" ];
  config.home = { imports = [ ./home.nix ]; };
}
