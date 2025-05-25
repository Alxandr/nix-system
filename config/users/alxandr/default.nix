{
  trusted = true;

  programs._1password.enable = true;

  # user.name = "notalxandr";
  user.extraGroups = [
    "wheel"
    "networkmanager"
    "keys"
    "dialout"
  ];

  home = ./home.nix;
}
