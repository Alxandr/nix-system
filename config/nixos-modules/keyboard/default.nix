{ config, lib, ... }:

with lib;

let
  cfg = config.keyboard;
  eurkey = cfg.layouts.eurkey;
in

{
  options.keyboard.layouts.eurkey = {
    enable = mkEnableOption "EurKEY layout" // {
      default = true;
    };
  };

  config = mkMerge [
    (mkIf eurkey.enable {
      services.xserver.xkb.extraLayouts.eurkey = {
        description = "EurKEY layout";
        languages = [ "eng" ];
        symbolsFile = ./eurkey/eurkey-1.2;
      };
    })
  ];
}
