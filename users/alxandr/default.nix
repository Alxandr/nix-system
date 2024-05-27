{ lib, user, host, homeModules, pkgs, system, ... }:
let inherit (lib) mkIf;
in {
  config = {
    trusted = true;
    user.extraGroups = [ "wheel" "networkmanager" ];
    user.packages = with pkgs; [
      brave
      vlc
      jellyfin-media-player
      _1password
      _1password-gui
      (mkIf (system == "x86_64-linux") spotify)
      signal-desktop
      element-desktop
    ];
    home = { imports = [ ./home.nix ]; };
  };
}
