{ pkgs, ... }:

{
  # Since we're using fish as our shell
  programs.zsh.enable = true;

  users.users.alxandr = {
    isNormalUser = true;
    home = "/home/mitchellh";
    extraGroups = [
			"docker"
			"wheel"
			"networkmanager"
		];
    shell = pkgs.zsh;
    hashedPassword = "$6$rounds=2000000$JIr43shw5plP$XiTLGulgJnPLyIFZIh/rEavBnIWU5bK/oEakZDMgf63QJkaRJ2g7frFza8YoKy315BZotK3oBB6nEYtUNONNq1";
    openssh.authorizedKeys.keys = [
      # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGbTIKIPtrymhvtTvqbU07/e7gyFJqNS4S0xlfrZLOaY mitchellh"
    ];
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix)
  ];
}
