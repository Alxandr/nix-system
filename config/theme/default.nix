{ lib, pkgs, ... }:
{
  config.stylix = {
    enable = lib.mkDefault true;
    image = ./bg.jpg;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/chalk.yaml";
  };

  config.home-manager.sharedModules = [
    (
      { config, ... }:
      {
        config.gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      }
    )
  ];
}
