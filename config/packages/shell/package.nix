{ pkgs, ags, ... }:
ags.lib.bundle {
  inherit pkgs;
  src = ./src;
  name = "shell";
  entry = "app.ts";
  gtk4 = true;

  # additional libraries and executables to add to gjs' runtime
  extraPackages = with ags; [
    hyprland
    battery
    bluetooth
    mpris
    network
    powerprofiles
    tray
    wireplumber
  ];
}
