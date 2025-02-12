{
  trusted = true;

  programs._1password.enable = true;

  # user.name = "notalxandr";
  user.extraGroups = [
    "wheel"
    "networkmanager"
    "keys"
  ];

  home = ./home.nix;
}
