{
  pkgs,
  lib,
  osConfig,
  config,
  ...
}:

with lib;

let
  inherit (pkgs)
    kitty
    swaynotificationcenter
    tofi
    _1password-gui
    ;

  isDesktop = osConfig.workloads.desktop.enable;
  enableHyprland = isDesktop && osConfig.workloads.desktop.environment.hyprland.enable;

  jsonFormat = pkgs.formats.json { };

in

{
  wayland.windowManager.hyprland = {
    enable = enableHyprland;

    settings = {
      monitor = [
        "eDP-1,preferred,0x0,1.5"
        "desc:Samsung Electric Company LS27A600U HNMWA01347,preferred,auto-left,1"
        ",preferred,auto,1"
      ];

      input = {
        kb_layout = "eurkey";
        numlock_by_default = true;
        follow_mouse = 2;

        touchpad = {
          natural_scroll = true;
          clickfinger_behavior = true;
        };
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
      };

      decoration = {
        rounding = 10;

        blur = {
          enabled = true;
        };
      };

      animations = {
        enabled = true;
        animation = [
          "windows,1,7,default"
          "border,1,10,default"
          "fade,1,10,default"
          "workspaces,1,6,default"
        ];
      };

      dwindle = { };

      gestures = {
        workspace_swipe = false;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      # mouse binds
      bindm = [
        "SUPER,mouse:272,movewindow"
        "SUPER_SHIFT,mouse:272,resizewindow"
      ];

      # Keyboard binds
      binds =
        [
          "SUPER,RETURN,exec,${kitty}/bin/kitty"
          "SUPER,Q,killactive,"
          "SUPER,M,exit,"
          "SUPER,N,exec,${swaynotificationcenter}/bin/swaync-client -t"
          "SUPER,V,togglefloating,"
          "SUPER,F,fullscreen,1"
          "SUPER_SHIFT,F,fullscreen,0"
          "SUPER,SPACE,exec,exec-single ${tofi}/bin/tofi-drun --drun-launch=true --width 100% --height 100%"
          "SUPER,P,pseudo,"

          # move workspace to next monitor
          "SUPER_SHIFT,W,movecurrentworkspacetomonitor,+1"

          "SUPER,left,movefocus,l"
          "SUPER,right,movefocus,r"
          "SUPER,up,movefocus,u"
          "SUPER,down,movefocus,d"

          "CTRL_SHIFT,space,exec,${_1password-gui}/bin/1password --quick-access"
          # TODO: "SUPER_SHIFT,S,exec,snip-shot"
        ]
        ++ flatten (
          flip genList 10 (
            n':
            let
              n = toString (n' + 1);
            in
            [
              "SUPER,${n},workspace,${n}"
              "ALT,${n},movetoworkspace,${n}"
            ]
          )
        );
    };
  };

  home.packages = [
    kitty
    swaynotificationcenter

    # at-spi2-core is to minimize journalctl noise of:
    # "AT-SPI: Error retrieving accessibility bus address: org.freedesktop.DBus.Error.ServiceUnknown: The name org.a11y.Bus was not provided by any .service files"
    pkgs.at-spi2-core
  ];

  xdg.configFile = {
    "swaync/config.json".source = jsonFormat.generate "config.json" config.services.swaync.settings;
    "swaync/style.css" = lib.mkIf (config.services.swaync.style != null) {
      source =
        if builtins.isPath config.services.swaync.style || lib.isStorePath config.services.swaync.style then
          config.services.swaync.style
        else
          pkgs.writeText "swaync/style.css" config.services.swaync.style;
    };
  };

  systemd.user.services.swaync = {
    Unit = {
      Description = "Swaync notification daemon";
      Documentation = "https://github.com/ErikReider/SwayNotificationCenter";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${swaynotificationcenter}/bin/swaync";
      Restart = "on-failure";
    };

    Install.WantedBy = [ "hyprland-session.target" ];
  };
}
