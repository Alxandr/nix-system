{ user, host, homeModules, pkgs, ... }: {
  config = {
    trusted = true;
    user.extraGroups = [ "wheel" "networkmanager" ];
    user.packages = with pkgs; [ brave vlc jellyfin-media-player ];
    home = { imports = [ ./home.nix ]; };
  };
}
