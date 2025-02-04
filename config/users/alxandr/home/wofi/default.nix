{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

with lib;

let
  isDesktop = osConfig.workloads.desktop.enable;
in

{
  config.stylix.targets.wofi.enable = false;
  config.programs.wofi = mkIf isDesktop {
    enable = true;
    style = ''
      @import "${config.lib.alxandr.colors.path}";

      ${lib.readFile ./style.css}
    '';
    settings = {
      allow_images = true;
      width = 500;
      show = "drun";
      prompt = "run: ";
      height = 400;
      always_parse_args = true;
      show_all = true;
      term = "${pkgs.kitty}/bin/kitty";
      hide_scroll = true;
      print_command = true;
      insensitive = true;
      columns = 1;
    };
  };
}
