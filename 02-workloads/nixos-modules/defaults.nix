{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./lib-module.nix
    ./polyfills/xdg.nix
    ./defaults/all.nix
  ];

  config = {
    # Allow normal users to bind to low ports
    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

    # Setup GPG
    programs.gnupg.agent.enable = true;

    programs.vim.enable = true;

    programs.neovim.enable = true;
    programs.neovim.defaultEditor = true;

    # Enable netbird service
    services.netbird.enable = lib.mkDefault true;

    # Enable the firmware update service
    services.fwupd.enable = true;

    # Programs for all systems
    environment.systemPackages = with pkgs; [
      dig
      nss
      btop
      htop
      wget
      unzip
      parted
      tcpdump
      tparted
      ripgrep
      usbutils
      nfs-utils
      traceroute
      appimage-run
      attic-client
      wireguard-tools
    ];

    nix.settings = {
      # enable flakes globally
      experimental-features = [
        "nix-command"
        "flakes"
        "recursive-nix"
        "pipe-operators"
      ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = lib.mkDefault true;
  };
}
