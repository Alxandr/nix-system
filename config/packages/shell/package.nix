{ pkgs, ags, ... }:
ags.lib.bundle {
  inherit pkgs;
  src = ./src;
  name = "shell";
  entry = "app.ts";
  gtk4 = true;

  # additional libraries and executables to add to gjs' runtime
  extraPackages = with ags.packages; [
    hyprland
    battery
    bluetooth
    mpris
    network
    powerprofiles
    tray
    wireplumber

    # https://github.com/Aylur/ags/issues/678
    pkgs.gtk4
  ];
}
