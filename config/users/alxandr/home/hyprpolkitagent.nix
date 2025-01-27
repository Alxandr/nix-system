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
  options.services.hyprpolkitagent = {
    enable = lib.mkEnableOption "Hypridle, Hyprland's idle daemon";

    package = lib.mkPackageOption pkgs "hyprpolkitagent" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.hyprland-qt-support ];
    systemd.user.services.hyprpolkitagent = {
      Install = {
        WantedBy = [ config.wayland.systemd.target ];
      };

      Unit = {
        Description = "Hyprland Polkit Authentication Agent";
        ConditionEnvironment = "WAYLAND_DISPLAY";
        After = [ config.wayland.systemd.target ];
        PartOf = [ config.wayland.systemd.target ];
        # X-Restart-Triggers = lib.mkIf (cfg.settings != { })
        #   [ "${config.xdg.configFile."hypr/hypridle.conf".source}" ];
      };

      Service = {
        ExecStart = "${cfg.package}/libexec/hyprpolkitagent";
        Slice = "session.slice";
        TimeoutStopSec = "5sec";
        Restart = "on-failure";
      };
    };
  };
}
