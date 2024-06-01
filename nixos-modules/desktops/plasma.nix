{ pkgs, lib, ... }:

{

  imports = [ ./wayland.nix ./pipewire.nix ];

  services.desktopManager.plasma6.enable = lib.mkDefault true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    # settings.Wayland.SessionDir =
    #   "${pkgs.plasma5Packages.plasma-workspace}/share/wayland-sessions";
  };

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [ kwallet-pam ];
}
