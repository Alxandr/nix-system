{ pkgs, ... }:
{
  config.stylix = {
    image = ./bg.jpg;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
  };
}
