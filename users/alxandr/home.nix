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

  programs.git = {
    enable = true;
    extraConfig = {
      core = {
        symlinks = true;
      };

      alias = {
        wip = "commit -am 'WIP'";
      };

      color = {
        ui = "auto";
      };

      "color \"grep\"" = {
        match = "cyan bold";
        selected = "blue";
        context = "normal";
        filename = "magenta";
        linenumber = "green";
        separator = "yellow";
        function = "blue";
      };

      pretty = {
        line = "%C(auto)%h %<|(60,trunc)%s %C(green)%ad%C(auto)%d";
        detail = "%C(auto)%h %s%n  %C(yellow)by %C(blue)%an %C(magenta)<%ae> [%G?] %C(green)%ad%n %C(auto)%d%n";
      };

      init = {
        defaultBranch = "main";
      };

      push = {
        default = "upstream";
        autoSetupRemote = true;
      };

      credential = {
        helper = "cache --timeout=3600";
      };

      user = {
        useConfigOnly = true;
        name = "Aleksander Heintz";
        email = "alxandr@alxandr.me";
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA49cjFMWbxCAjTsK7H/r0biiBV0EGZHJR1xmik/arxA";
      };

      gpg = {
        format = "ssh";
      };

      "gpg \"ssh\"" = {
        program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };

      commit = {
        gpgsign = true;
      };

      tag = {
        gpgsign = true;
      };

      gitbutler = {
        signCommits = true;
      };

      http = {
        cookieFile = "~/.gitcookies";
      };
    };
  };

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
