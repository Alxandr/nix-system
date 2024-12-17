{ pkgs, lib, ... }: {
  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.zoxide.enable = true;

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      editorconfig.editorconfig
      jnoortheen.nix-ide

    ];
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
          IdentityAgent ~/.1password/agent.sock
    '';
  };

  # programs.git = {
  #   enable = true;
  #   extraConfig = {
  #     gpg = {
  #       format = "ssh";
  #     };

  #     "gpg \"ssh\"" = {
  #       program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
  #     };

  #     commit = {
  #       gpgsign = true;
  #     };

  #     tag = {
  #       gpgsign = true;
  #     };

  #     user = {
  #       useConfigOnly = true;
  #       name = "Aleksander Heintz";
  #       email = "alxandr@alxandr.me";
  #       signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA49cjFMWbxCAjTsK7H/r0biiBV0EGZHJR1xmik/arxA";
  #     };
  #   };
  # };

  home.packages = with pkgs; [
    nixpkgs-fmt
    nil
  ];

  # This value determines the home-manager release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option.
  home.stateVersion = "24.05"; # Did you read the comment?
}
