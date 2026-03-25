{ osConfig, ... }:
let
  isDesktop = osConfig.workloads.desktop.enable;

in
{
  trusted = true;

  programs._1password.enable = isDesktop;

  # user.name = "notalxandr";
  user.extraGroups = [
    "wheel"
    "networkmanager"
    "keys"
    "dialout"
  ];

  home = ./home.nix;
}
