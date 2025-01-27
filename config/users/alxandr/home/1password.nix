{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.autostart._1password-gui;
in
{
  options.autostart._1password-gui = {
    enable = lib.mkEnableOption "autostart 1password-gui";

    silent = lib.mkEnableOption "Start 1password-gui in silent mode" // {
      default = true;
    };

    package = lib.mkPackageOption pkgs "_1password-gui" { };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."autostart/1password.desktop".text = ''
      [Desktop Entry]
      Exec=${cfg.package}/bin/1password ${if cfg.silent then "--silent" else ""}
      Name=1password
      Type=Application
    '';
  };
}
