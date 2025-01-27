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
        config.gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
        config.stylix.targets.hyprland.enable = false;
      }
    )
  ];
}
