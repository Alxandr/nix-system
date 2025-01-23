{ lib, pkgs, ... }:
{
  config.stylix = {
    enable = lib.mkDefault true;
    image = ./bg.jpg;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
  };
}
