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
  terminalFont = "Cascadia Code NF";

in

{
  imports = [
    ./home/colors.nix
    ./home/shell.nix
    ./home/hypr.nix
    ./home/waybar
    ./home/wofi
    ./home/swaync
    ./home/zed.nix
  ];

  # TODO: https://github.com/danth/stylix/issues/865
  nixpkgs.overlays = lib.mkForce null;

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
    profiles.default = {
      extensions =
        (with pkgs.vscode-extensions; [
          eamodio.gitlens
          editorconfig.editorconfig
          esbenp.prettier-vscode
          fill-labs.dependi
          foxundermoon.shell-format
          github.copilot
          github.copilot-chat
          github.vscode-github-actions
          hashicorp.hcl
          jnoortheen.nix-ide
          mkhl.direnv
          ms-python.debugpy
          ms-python.python
          ms-python.vscode-pylance
          ms-vscode-remote.remote-containers
          ms-vscode.cmake-tools
          ms-vscode.cpptools
          ms-vscode.cpptools-extension-pack
          pkief.material-icon-theme
          redhat.ansible
          redhat.vscode-xml
          redhat.vscode-yaml
          rust-lang.rust-analyzer
          samuelcolvin.jinjahtml
          signageos.signageos-vscode-sops
          skellock.just
          tamasfe.even-better-toml
          usernamehw.errorlens
          vadimcn.vscode-lldb
        ])
        ++ (with pkgs.vscode-marketplace; [
          arktypeio.arkdark
          fengtan.ldap-explorer
          jscearcy.rust-doc-viewer
          opentofu.vscode-opentofu
          oven.bun-vscode
        ]);

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
            "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";
            "nix.serverSettings"."nil" = {
              "formatting"."command" = [ "${pkgs.nixfmt}/bin/nixfmt" ];
              "nix"."maxMemoryMB" = 12560;
              "nix"."flake" = {
                "autoArchive" = true;
                "autoEvalInputs" = true;
              };
            };
            "redhat.telemetry.enabled" = true;
            "github.copilot.nextEditSuggestions.enabled" = true;
          }
          (
            {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            }
            |> perLang [
              "css"
              "javascript"
              "javascriptreact"
              "json"
              "jsonc"
              "scss"
              "typescript"
              "typescriptreact"
              "yaml"
            ]
          )
        ]
        |> flatten
        |> mkMerge;
    };
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
    lfs.enable = true;

    userName = "Aleksander Heintz";
    userEmail = "alxandr@alxandr.me";

    aliases = {
      wip = "commit -am 'WIP'";
    };

    signing = {
      format = "ssh";
      signByDefault = true;
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA49cjFMWbxCAjTsK7H/r0biiBV0EGZHJR1xmik/arxA";
      signer = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
    };

    extraConfig = {
      core.symlinks = true;

      color.ui = "auto";

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

      init.defaultBranch = "main";

      push = {
        default = "upstream";
        autoSetupRemote = true;
      };

      credential.helper = "cache --timeout=3600";

      user = {
        useConfigOnly = true;
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA49cjFMWbxCAjTsK7H/r0biiBV0EGZHJR1xmik/arxA";
      };

      gitbutler.signCommits = true;

      http.cookieFile = "~/.gitcookies";

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
        nh
        nil
        nixfmt
        nixpkgs-fmt
      ]
      ++ optionals isDesktop [
        # gitbutler
      ]
    );

  # temp hack
  xdg.configFile."autostart/kde-theme-activate.desktop".text =
    let
      apply = pkgs.writeShellApplication {
        name = "apply-kde-lookandfeel";
        text = ''
          ${pkgs.xvfb-run}/bin/xvfb-run ${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-lookandfeel --apply stylix
        '';
      };
    in
    ''
      [Desktop Entry]
      Exec=${apply}/bin/apply-kde-lookandfeel
      Name=apply-kde-lookandfeel
      Type=Application
    '';

  # This value determines the home-manager release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option.
  home.stateVersion = "24.05"; # Did you read the comment?
}
