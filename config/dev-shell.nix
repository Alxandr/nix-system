{ pkgs, packages }:
pkgs.mkShell {
  packages = with pkgs; [
    ssh-to-age
    sops
    just
    typescript
    nodejs_22
    (packages.ags.override {
      extraPackages = with packages.ags.packages; [
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

  shellHook = ''
    mkdir -p node_modules
    ln -sf "${packages.ags.packages.gjs}/share/astal/gjs" node_modules/astral
  '';
}
