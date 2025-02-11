{
  lib,
  pkgs,
  ...
}:

let
  wallpaper = ./bg.jpg;

in
{
  config.stylix = {
    enable = lib.mkDefault true;
    image = wallpaper;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/chalk.yaml";

    fonts.monospace = {
      name = "Fira Code";
      package = pkgs.fira-code;
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
  };

  config.environment.systemPackages = [
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background=${wallpaper}
      type=image
    '')
  ];

  config.home-manager.sharedModules = [
    (
      { config, ... }:
      {
        # Something overwrites the default gtk2 config location, which causes home-manager
        # to fail activation. This forces the file location elsewhere such that there is no
        # conflict.
        config = {
          gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
          stylix.targets.hyprland.enable = false;

          # https://github.com/danth/stylix/issues/835
          qt = {
            enable = true;
            platformTheme.package = with pkgs.kdePackages; [
              plasma-integration
              # I don't remember why I put this is here, maybe it fixes the theme of the system setttings
              systemsettings
            ];
            style = {
              package = pkgs.kdePackages.breeze;
              name = lib.mkForce "Breeze";
            };
          };
          systemd.user.sessionVariables = {
            QT_QPA_PLATFORMTHEME = lib.mkForce "kde";
          };
        };
      }
    )
  ];
}
