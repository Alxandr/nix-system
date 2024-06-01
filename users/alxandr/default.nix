{ lib, user, host, homeModules, pkgs, system, ... }:
let inherit (lib) mkIf;
in {
  config = {
    trusted = true;
    user.extraGroups = [ "wheel" "networkmanager" ];
    home = { imports = [ ./home.nix ]; };
  };
}
