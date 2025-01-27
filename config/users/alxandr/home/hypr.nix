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
    uwsm
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

    # conflicts with uwsm
    systemd.enable = false;

    settings =
      let
        app = cmd: "${uwsm}/bin/uwsm app -- ${cmd}";
        mainMod = "SUPER";

        terminal = app "${kitty}/bin/kitty";
        swaync-client = app "${swaynotificationcenter}/bin/swaync-client";
        tofi-drun = app "${tofi}/bin/tofi-drun";
      in
      {
        ################
        ### MONITORS ###
        ################
        monitor = [
          "eDP-1, preferred, 0x0, 1.5"
          "desc:Samsung Electric Company LS27A600U HNMWA01347, preferred, auto-left, 1"
          ", preferred, auto, 1"
        ];

        #####################
        ### LOOK AND FEEL ###
        #####################
        # https://wiki.hyprland.org/Configuring/Variables/#general
        general = {
          gaps_in = 5;
          gaps_out = 20;

          border_size = 2;

          # Set to true enable resizing windows by clicking and dragging on borders and gaps
          resize_on_border = false;

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false;

          layout = "dwindle";
        };

        # https://wiki.hyprland.org/Configuring/Variables/#decoration
        decoration = {
          rounding = 10;
          # rounding_power = 2;

          # Change transparency of focused and unfocused windows
          active_opacity = 1.0;
          inactive_opacity = 1.0;

          # https://wiki.hyprland.org/Configuring/Variables/#blur
          blur = {
            enabled = true;
            size = 3;
            passes = 1;

            vibrancy = 0.1696;
          };
        };

        # https://wiki.hyprland.org/Configuring/Variables/#animations
        animations = {
          enabled = true;

          bezier = [
            "easeOutQuint,0.23,1,0.32,1"
            "easeInOutCubic,0.65,0.05,0.36,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];

          animation = [
            "global, 1, 10, default"
            "border, 1, 5.39, easeOutQuint"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "fade, 1, 3.03, quick"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "workspaces, 1, 1.94, almostLinear, fade"
            "workspacesIn, 1, 1.21, almostLinear, fade"
            "workspacesOut, 1, 1.94, almostLinear, fade"
          ];
        };

        # https://wiki.hyprland.org/Configuring/Variables/#misc
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };

        #############
        ### INPUT ###
        #############
        # https://wiki.hyprland.org/Configuring/Variables/#input
        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";

          numlock_by_default = true;
          follow_mouse = 2;

          touchpad = {
            natural_scroll = true;
            clickfinger_behavior = true;
          };
        };

        # https://wiki.hyprland.org/Configuring/Variables/#gestures
        gestures = {
          workspace_swipe = false;
        };

        ################
        ### BINDINGS ###
        ################

        # mouse binds
        bindm = [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "${mainMod}, mouse:272, movewindow"
          "${mainMod}, mouse:273, resizewindow"

          # Resize windows with mainMod + SHIFT + LMB and dragging
          "${mainMod} SHIFT, mouse:272, resizewindow"
        ];

        # Keyboard binds
        binds = flatten [
          # See https://wiki.hyprland.org/Configuring/Binds/ for more
          "${mainMod}, RETURN, exec, ${terminal}"
          "${mainMod}, Q, killactive,"
          "${mainMod}, M, exit," # TODO: replace with uwsm exit
          "${mainMod}, N, exec, ${swaync-client} -t"
          "${mainMod}, V, togglefloating,"
          "${mainMod}, F, fullscreen, 1"
          "${mainMod} SHIFT, F, fullscreen, 0"
          "${mainMod}, SPACE, exec, ${tofi-drun} --drun-launch=true --width 100% --height 100%"
          "${mainMod}, P, pseudo," # dwindle layout
          "${mainMod}, J, togglesplit," # dwindle layout

          # Move focus with mainMod + arrow keys
          "${mainMod}, left, movefocus, l"
          "${mainMod}, right, movefocus, r"
          "${mainMod}, up, movefocus, u"
          "${mainMod}, down, movefocus, d"

          # Switch workspaces with mainMod + [0-9]
          "${mainMod}, 1, workspace, 1"
          "${mainMod}, 2, workspace, 2"
          "${mainMod}, 3, workspace, 3"
          "${mainMod}, 4, workspace, 4"
          "${mainMod}, 5, workspace, 5"
          "${mainMod}, 6, workspace, 6"
          "${mainMod}, 7, workspace, 7"
          "${mainMod}, 8, workspace, 8"
          "${mainMod}, 9, workspace, 9"
          "${mainMod}, 0, workspace, 10"

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "${mainMod} SHIFT, 1, movetoworkspace, 1"
          "${mainMod} SHIFT, 2, movetoworkspace, 2"
          "${mainMod} SHIFT, 3, movetoworkspace, 3"
          "${mainMod} SHIFT, 4, movetoworkspace, 4"
          "${mainMod} SHIFT, 5, movetoworkspace, 5"
          "${mainMod} SHIFT, 6, movetoworkspace, 6"
          "${mainMod} SHIFT, 7, movetoworkspace, 7"
          "${mainMod} SHIFT, 8, movetoworkspace, 8"
          "${mainMod} SHIFT, 9, movetoworkspace, 9"
          "${mainMod} SHIFT, 0, movetoworkspace, 10"

          # Example special workspace (scratchpad)
          "${mainMod}, S, togglespecialworkspace, scratchpad"
          "${mainMod} SHIFT, S, movetoworkspace, special:scratchpad"

          # move workspace to next monitor
          "${mainMod} SHIFT, W, movecurrentworkspacetomonitor,+1"
        ];

        # Special key binds (media keys)
        # bindel runs even when lockscreen is active, and is repeated when key is held
        bindel = [
          # # Laptop multimedia keys for volume and LCD brightness
          # ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          # ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          # ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          # ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          # ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
          # ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
        ];

        # bindl runs even when lockscreen is active, but is not repeated when key is held
        bindl = [
          # # Requires playerctl
          # ", XF86AudioNext, exec, playerctl next"
          # ", XF86AudioPause, exec, playerctl play-pause"
          # ", XF86AudioPlay, exec, playerctl play-pause"
          # ", XF86AudioPrev, exec, playerctl previous"
        ];

        ##############################
        ### WINDOWS AND WORKSPACES ###
        ##############################
        windowrulev2 = [
          # Fix some dragging issues with XWayland
          "nofocus, class:^$, title:^$, xwayland:1, floating:1, fullscreen:0, pinned:0"
        ];
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

  # systemd.user.services.swaync = {
  #   Unit = {
  #     Description = "Swaync notification daemon";
  #     Documentation = "https://github.com/ErikReider/SwayNotificationCenter";
  #     PartOf = [ "hyprland-session.target" ];
  #     After = [ "hyprland-session.target" ];
  #     ConditionEnvironment = "WAYLAND_DISPLAY";
  #   };

  #   Service = {
  #     Type = "dbus";
  #     BusName = "org.freedesktop.Notifications";
  #     ExecStart = "${swaynotificationcenter}/bin/swaync";
  #     Restart = "on-failure";
  #   };

  #   Install.WantedBy = [ "hyprland-session.target" ];
  # };
}
