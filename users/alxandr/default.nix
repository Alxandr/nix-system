{ user, host, homeModules, ... }: {
  config.user.extraGroups = [ "wheel" "networkmanager" ];
  config.home = {
    imports = [ homeModules.neovim ./home.nix ];
  };
}
