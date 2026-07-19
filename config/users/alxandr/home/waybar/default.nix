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
  enableHyprland = isDesktop && osConfig.workloads.desktop.environment.hyprland.enable;
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
in

{
  config.stylix.targets.waybar.enable = false;
  config.programs.waybar = mkIf enableHyprland {
    enable = true;
    systemd.enable = true;
    systemd.targets = [ "tray.target" ];
    style = ''
      @import "${config.lib.alxandr.colors.path}";

      ${lib.readFile ./style.css}
    '';
    settings = {
      main_bar = {
        layer = "top";
        position = "top";
        # "height" = 34;

        ########################################
        # MODULES
        ########################################
        modules-left = [
          "custom/notification"
          "clock"
          # "custom/pacman"
          "tray"
        ];
        modules-center = [
          "hyprland/workspaces"
          # "hyprland/window"
        ];
        modules-right = [
          "group/expand"
          "pulseaudio"
          "backlight"
          (mkIf osConfig.hardware.bluetooth.enable "bluetooth")
          "network"
          "battery"
        ];

        ########################################
        # MODULE CONFIGURATION
        ########################################
        "hyprland/workspaces" = {
        };

        "custom/notification" = {
          tooltip = false;
          format = "";
          on-click = "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
          escape = true;
        };

        clock = {
          format = "{:%H:%M:%S} ";
          interval = 1;
          tooltip-format = "{:%a  ·  %d.%m.%Y}";
        };

        network = {
          format-wifi = "{icon}";
          format-ethernet = "🖧";
          format-disconnected = "󰤮";
          tooltip-format-disconnected = "Error";
          tooltip-format-wifi = "{essid} ({signalStrength}%) {icon}";
          tooltip-format-ethernet = "{ifname} 🖧 ";
          # TODO: replace with a nice wifi gui?
          on-click = "${pkgs.ghostty}/bin/ghostty -e ${pkgs.networkmanager}/bin/nmtui";
          format-icons = [
            "󰤯"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
        };

        bluetooth = {
          format-on = "󰂯";
          format-off = "BT-off";
          format-disabled = "󰂲";
          format-connected-battery = "{device_battery_percentage}% 󰂯";
          format-alt = "{device_alias} 󰂯";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\n{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\n{device_address}\n{device_battery_percentage}%";
          on-click-right = "${pkgs.blueman}/bin/blueman-manager";
        };

        battery = {
          interval = 30;
          states.good = 95;
          states.warning = 30;
          states.critical = 20;

          # tooltip = true;
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% 󰂄";
          format-plugged = "{capacity}% 󰂄 ";
          format-alt = "{time} {icon}";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };

        "custom/expand" = {
          format = "";
          tooltip = false;
        };

        "custom/endpoint" = {
          format = "|";
          tooltip = false;
        };

        "group/expand" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 600;
            transition-to-left = true;
            click-to-reveal = true;
          };

          modules = [
            "custom/expand"
            # "custom/colorpicker"
            "cpu"
            "memory"
            "temperature"
            "custom/endpoint"
          ];
        };

        cpu = {
          format = "󰻠";
          tooltip = true;
        };

        memory = {
          format = "";
        };

        temperature = {
          critical-threshold = 80;
          format = "";
          format-critical = "";
        };

        pulseaudio = {
          format = "{icon}";
          format-bluetooth = "{icon}";
          format-muted = "";
          format-icons = {
            headphone = "";
            # "hands-free" = "";
            # "headset" = "";
            phone = "";
            portable = "";
            default = "";
          };
          tooltip-format = "{volume}% {icon}";
          scroll-step = 1;
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        };

        backlight = {
          device = "intel_backlight";
          # "format" = "{percent}% {icon}";
          format = "{icon}";
          format-icons = [
            "󱩎"
            "󱩏"
            "󱩐"
            "󱩑"
            "󱩒"
            "󱩓"
            "󱩔"
            "󱩕"
            "󱩖"
            "󰛨"
          ];
          tooltip-format = "{percent}% {icon}";
          on-scroll-down = "${brightnessctl} s -- +1%";
          on-scroll-up = "${brightnessctl} s -- -1%";
        };

        tray = {
          icon-size = 14;
          spacing = 10;
        };
      };
    };
  };
}
