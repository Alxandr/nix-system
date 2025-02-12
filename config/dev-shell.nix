{ pkgs, packages }:
pkgs.mkShell {
  packages = with pkgs; [
    ssh-to-age
    sops
    just
    (packages.ags.override {
      extraPackages = with packages.ags; [
        hyprland
        battery
        bluetooth
        mpris
        network
        powerprofiles
        tray
        wireplumber
      ];
    })
  ];
}
