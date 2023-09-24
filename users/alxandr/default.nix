{ user, host, ... }: {
  config.user.extraGroups = [ "wheel" "networkmanager" ];
  config.home = ./home.nix;
}
