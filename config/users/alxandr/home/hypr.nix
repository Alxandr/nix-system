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

in

{
  config = mkIf enableHyprland {
    wayland.windowManager.hyprland = {
      enable = true;

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
          # See https://wiki.hyprland.org/Configuring/Monitors/
          monitor = [
            ", preferred, auto, 1"
            # ",preferred,auto,auto"
          ];

          #####################
          ### LOOK AND FEEL ###
          #####################
          # https://wiki.hyprland.org/Configuring/Variables/#general
          general = {
            gaps_in = 5;
            gaps_out = 20;

            border_size = 2;

            "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
            "col.inactive_border" = "rgba(595959aa)";

            # Set to true enable resizing windows by clicking and dragging on borders and gaps
            resize_on_border = false;

            # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
            allow_tearing = false;

            layout = "dwindle";
          };

          # https://wiki.hyprland.org/Configuring/Variables/#decoration
          decoration = {
            rounding = 10;

            # Change transparency of focused and unfocused windows
            active_opacity = 1.0;
            inactive_opacity = 1.0;

            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
              color = "rgba(1a1a1aee)";
            };

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

            # numlock_by_default = true;
            follow_mouse = 2;
            sensitivity = 0;

            touchpad = {
              natural_scroll = true;
              clickfinger_behavior = true;
            };
          };

          # https://wiki.hyprland.org/Configuring/Variables/#gestures
          gestures = {
            workspace_swipe = false;
          };

          ##############
          ### CURSOR ###
          ##############
          cursor = {
            inactive_timeout = 15;
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
          bind = flatten [
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

          #############
          ### DEBUG ###
          #############
          # debug = {
          #   disable_logs = false;
          #   disable_time = false;
          # };
        };
    };

    services.swaync.enable = true;
    services.hypridle.enable = true;

    programs.tofi = {
      enable = true;
      settings = {
        #
        ### Fonts
        #
        # Font to use, either a path to a font file or a name.
        #
        # If a path is given, tofi will startup much quicker, but any
        # characters not in the chosen font will fail to render.
        #
        # Otherwise, fonts are interpreted in Pango format.
        font = mkForce "${pkgs.fira-code}/share/fonts/truetype/FiraCode-VF.ttf";

        # Point size of text.
        font-size = mkForce 24;

        # Perform font hinting. Only applies when a path to a font has been
        # specified via `font`. Disabling font hinting speeds up text
        # rendering appreciably, but will likely look poor at small font pixel
        # sizes.
        hint-font = true;

        #
        ### Colors
        #
        # Window background
        background-color = mkDefault "#000A";

        # Border outlines
        outline-color = mkDefault "#080800";

        # Border
        border-color = mkDefault "#F92672";

        # Default text
        text-color = mkDefault "#FFFFFF";

        # Selection text
        selection-color = mkDefault "#F92672";

        # Matching portion of selection text
        selection-match-color = mkDefault "#00000000";

        # Selection background
        selection-background = mkDefault "#00000000";

        #
        ### Text layout
        #
        # Prompt to display.
        prompt-text = "\"run: \"";

        # Extra horizontal padding between prompt and input.
        prompt-padding = 0;

        # Maximum number of results to display.
        # If 0, tofi will draw as many results as it can fit in the window.
        num-results = 10;

        # Spacing between results in pixels. Can be negative.
        result-spacing = 25;

        # List results horizontally.
        horizontal = false;

        # Minimum width of input in horizontal mode.
        min-input-width = 0;

        # Extra horizontal padding of the selection background in pixels.
        selection-padding = 0;

        #
        ### Window layout
        #
        # Width and height of the window. Can be pixels or a percentage.
        width = "100%";
        height = "100%";

        # Width of the border outlines in pixels.
        outline-width = 0;

        # Width of the border in pixels.
        border-width = 0;

        # Radius of window corners in pixels.
        corner-radius = 0;

        # Padding between borders and text. Can be pixels or a percentage.
        padding-top = "35%";
        padding-bottom = 0;
        padding-left = "35%";
        padding-right = 0;

        # Whether to scale the window by the output's scale factor.
        scale = true;

        #
        ### Window positioning
        #
        # The name of the output to appear on. An empty string will use the
        # default output chosen by the compositor.
        output = "";

        # Location on screen to anchor the window to.
        #
        # Supported values: top-left, top, top-right, right, bottom-right,
        # bottom, bottom-left, left, center.
        anchor = "center";

        # Window offset from edge of screen. Only has an effect when anchored
        # to the relevant edge. Can be pixels or a percentage.
        margin-top = 0;
        margin-bottom = 0;
        margin-left = 0;
        margin-right = 0;

        #
        ### Behaviour
        #
        # Hide the cursor.
        hide-cursor = false;

        # Sort results by number of usages in run and drun modes.
        history = true;

        # Use fuzzy matching for searches.
        fuzzy-match = true;

        # If true, require a match to allow a selection to be made. If false,
        # making a selection with no matches will print input to stdout.
        # In drun mode, this is always true.
        require-match = true;

        # If true, directly launch applications on selection when in drun mode.
        # Otherwise, just print the command line to stdout.
        drun-launch = false;

        # Delay keyboard initialisation until after the first draw to screen.
        # This option is experimental, and will cause tofi to miss keypresses
        # for a short time after launch. The only reason to use this option is
        # performance on slow systems.
        late-keyboard-init = false;
      };
    };

    home.packages = [ pkgs.fira-code ];
  };
}
