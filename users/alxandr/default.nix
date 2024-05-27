{ user, host, homeModules, pkgs, ... }: {
  config = {
    trusted = true;
    user.extraGroups = [ "wheel" "networkmanager" ];
    user.packages = with pkgs; [
      brave
      vlc
      jellyfin-media-player
      _1password
      _1password-gui
      spotify
      signal-desktop
      element-desktop
    ];
    home = { imports = [ ./home.nix ]; };
  };
}
