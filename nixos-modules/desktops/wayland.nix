{ pkgs, ... }:

{

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1"; # for VSCode Discord etc
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs;
        [
          xdg-desktop-portal-wlr
          #xdg-desktop-portal-gtk
        ];
    };
  };

  environment.systemPackages = with pkgs; [
    wayland-utils
    xwayland
    xwaylandvideobridge
  ];
}
