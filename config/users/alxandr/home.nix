{
  pkgs,
  lib,
  osConfig,
  ...
}:

with lib;

let
  isDesktop = osConfig.workloads.desktop.enable;
  terminalFont = "Cascadia Code NF";

in

{
  imports = [
    ./home/shell.nix
    ./home/hypr.nix
  ];

  programs.home-manager.enable = true;
  programs.kitty = mkIf isDesktop {
    enable = true;
    font.name = mkForce terminalFont;
    font.package = mkForce pkgs.cascadia-code;
  };

  programs.vscode = mkIf isDesktop {
    enable = true;
    # package = pkgs.vscode.override {
    #   commandLineArgs = "--password-store=\"kwallet5\"";
    # };

    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-extensions; [
      eamodio.gitlens
      editorconfig.editorconfig
      esbenp.prettier-vscode
      fill-labs.dependi
      github.copilot
      github.copilot-chat
      github.vscode-github-actions
      jnoortheen.nix-ide
      mkhl.direnv
      pkief.material-icon-theme
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
    ];

    userSettings =
      let
        perLang = langs: conf: genAttrs (langs |> map (l: "[${l}]")) (v: conf);

      in
      [
        {
          "window.titleBarStyle" = "custom";
          "terminal.integrated.fontFamily" = terminalFont;
          "editor.formatOnSave" = true;
          "editor.tabSize" = 2;
          "workbench.iconTheme" = "material-icon-theme";
          "nix.enableLanguageServer" = true;
          "nix.formatterPath" = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          "nix.serverSettings"."nil" = {
            "formatting"."command" = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
            "nix"."maxMemoryMB" = 12560;
            "nix"."flake" = {
              "autoArchive" = true;
              "autoEvalInputs" = true;
            };
          };
        }
        (
          {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          }
          |> perLang [
            "jsonc"
            "json"
            "javascript"
            "javascriptreact"
            "typescript"
            "typescriptreact"
            "scss"
          ]
        )
      ]
      |> flatten
      |> mkMerge;
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
    ignores = [
      # Logs and databases #
      ######################
      "*.log"
      "*.sqlite"

      # OS generated files #
      ######################
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "Icon?"
      "ehthumbs.db"
      "Thumbs.db"
    ];
  };

  home.packages =
    with pkgs;
    (
      [
        nixpkgs-fmt
        nixfmt-rfc-style
        nil
        nh
      ]
      ++ optionals isDesktop [
        gitbutler
      ]
    );

  # temp hack
  xdg.configFile."autostart/kde-theme-activate.desktop".text = ''
    [Desktop Entry]
    Exec=${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-lookandfeel --apply stylix
    Name=1password
    Type=Application
  '';

  # This value determines the home-manager release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option.
  home.stateVersion = "24.05"; # Did you read the comment?
}
