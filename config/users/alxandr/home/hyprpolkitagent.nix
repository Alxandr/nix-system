{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hyprpolkitagent;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.hyprland-qt-support ];
    systemd.user.services.hyprpolkitagent = {
      Unit = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
        # X-Restart-Triggers = lib.mkIf (cfg.settings != { })
        #   [ "${config.xdg.configFile."hypr/hypridle.conf".source}" ];
      };

      Service = {
        Slice = "session.slice";
      };
    };
  };
}
