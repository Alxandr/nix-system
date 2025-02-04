{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  colorsCss = pkgs.writeTextFile {
    name = "colors.css";
    text = with config.lib.stylix.colors.withHashtag; ''
      /* -----------------------------------------------------------------------------
       * Colors from stylix
       * -------------------------------------------------------------------------- */
      @define-color background ${base00};
      @define-color color1 ${base01};
      @define-color color2 ${base02};
      @define-color color3 ${base03};
      @define-color color4 ${base04};
      @define-color color5 ${base05};
      @define-color color6 ${base06};
      @define-color color7 ${base07};
      @define-color color8 ${base08};
      @define-color color9 ${base09};
    '';
  };

in
{
  config.lib.alxandr.colors.path = "${colorsCss}";
  # options.lib.alxandr.colors = mkOption {
  #   type = types.path;
  #   default = "${colorsCss}";
  # };
}
