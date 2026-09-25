{
  yoloproj,
  config,
  ...
}:
let
  nixosConfig = config;
in
{
  # syncthing ports
  config.networking.firewall = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [
      22000
      21027
    ];
  };

  config.home-manager.users.alxandr =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      herdrCodexHook = "${config.home.homeDirectory}/.codex/herdr-agent-state.sh";
      herdrCodexHookCommand = "bash '${herdrCodexHook}' session";
      herdrCodexHookIdentity = builtins.toJSON {
        event_name = "session_start";
        hooks = [
          {
            async = false;
            command = herdrCodexHookCommand;
            timeout = 10;
            type = "command";
          }
        ];
      };
      herdrCodexHookTrustHash =
        "sha256:"
        + builtins.convertHash {
          hash = builtins.hashString "sha256" herdrCodexHookIdentity;
          hashAlgo = "sha256";
          toHashFormat = "base16";
        };

      dotnet =
        let
          combined =
            with pkgs.dotnetCorePackages;
            combinePackages [
              sdk_10_0
              sdk_9_0
              sdk_8_0
            ];

          # copied = pkgs.runCommand "dotnet" { } ''
          #   mkdir -p "$out"/share/dotnet
          #   cp -aL "${combined}"/share/dotnet/. "$out"/share/dotnet/

          #   cp -aL "${combined}"/nix-support "$out"/nix-support

          #   mkdir -p "$out"/bin
          #   ln -s "$out"/share/dotnet/dotnet "$out"/bin/dotnet
          # '';
        in
        combined;

    in
    {
      services.syncthing = {
        enable = true;

        settings = {
          devices = {
            pangolin.id = "KPHJWQF-JCO6KG3-KPOIYHV-2XKRQAN-NYIDCJG-7QNFJ73-CDM2CJR-57EREAX";
            pangolin.addresses = [ "tcp://pangolin.alxandr.me:22000" ];
          };

          folders = {
            codex-memories = {
              enable = true;
              path = "~/.codex/memories";
              devices = [ "pangolin" ];
            };
          };
        };
      };

      programs.mcp.enable = true;
      programs.mcp.servers = {
        glider = {
          command = "${lib.getExe pkgs.nur.repos.Alxandr.glider-mcp}";
          args = [
            "--transport"
            "stdio"
          ];
        };

        nuget = {
          command = "${lib.getExe pkgs.nur.repos.Alxandr.dimon-smart-nuget-mcp-server}";
        };

        context7 = {
          command = "${lib.getExe pkgs.context7-mcp}";
        };

        # TODO: enable after secrets work
        # github = {
        #   url = "https://api.githubcopilot.com/mcp/";
        #   bearer_token_env_var = "MCP_GITHUB_PAT"; # codex specific syntax
        #   headers = {
        #     "X-MCP-Toolsets" = "context,repos,issues,users,projects,pull_requests,labels";
        #   };
        # };

        # context7 = {
        #   url = "https://mcp.context7.com/mcp";
        #   headers = {
        #     CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
        #   };
        # };
      };

      programs.codex = {
        enable = true;
        enableMcpIntegration = true;

        context = ./AGENTS.md;
        skills.dotnet = ./skills/dotnet;
        skills.but = "${pkgs.nur.repos.Alxandr.gitbutler-cli.skill}";

        settings = {
          model = "gpt-5.6-sol";
          model_reasoning_effort = "medium";
          project_doc_fallback_filenames = [ "CLAUDE.md" ];

          tui.status_line = [
            "model-with-reasoning"
            "current-dir"
            "context-used"
            "weekly-limit"
            "five-hour-limit"
          ];
          tui.status_line_use_colors = true;

          features.memories = true;
          features.context_management.experimental_mode = true;

          projects =
            let
              projects = [
                "altinn/register"
                "altinn/auth-tmp"
                "altinn/auth-utils"
                "altinn/source"
                "nix-system"
                "home-cluster"
                "nur"
                "sure"
              ];
            in
            builtins.listToAttrs (
              map (proj: {
                name = "/home/alxandr/hub/${proj}";
                value = {
                  trust_level = "trusted";
                };
              }) projects
            );

          # Codex compares this hash to the normalized hook definition, so it
          # is reviewed again automatically if the hook changes.
          hooks = {
            SessionStart = [
              {
                hooks = [
                  {
                    type = "command";
                    command = herdrCodexHookCommand;
                    timeout = 10;
                  }
                ];
              }
            ];

            state = {
              "${config.home.homeDirectory}/.codex/config.toml:session_start:0:0".trusted_hash =
                herdrCodexHookTrustHash;
            };
          };

          mcp_servers = {
            github = {
              url = "https://api.githubcopilot.com/mcp/";
              bearer_token_env_var = "MCP_GITHUB_PAT";
              headers = {
                "X-MCP-Toolsets" = "context,repos,issues,users,projects,pull_requests,labels";
              };
            };
          };
        };
      };

      # programs.opencode = {
      #   enable = true;
      #   enableMcpIntegration = true;

      #   skills.dotnet = ./skills/dotnet;
      # };

      programs.gh.enable = true;
      programs.gh.gitCredentialHelper.enable = false; # we use 1password for this

      home.packages = [
        pkgs.bun # javascript runtime
        pkgs.docker-compose # docker compose cli
        pkgs.nur.repos.Alxandr.dotnet-verify # tool for snapshot testing of .NET projects
        pkgs.dotnet-repl # polyglot .NET REPL
        pkgs.nur.repos.Alxandr.glider-mcp # mcp server for .NET
        pkgs.helm # kubernetes package manager
        pkgs.jq # command-line JSON processor
        pkgs.just # command runner for dev tasks
        pkgs.kubectl # kubernetes cli
        pkgs.kubelogin # kubernetes oidc login helper
        pkgs.nur.repos.Alxandr.dimon-smart-nuget-mcp-server # mcp server for nuget packages
        pkgs.pnpm # package manager for node
        pkgs.powershell # shell
        pkgs.prek # pre-commit hooks
        pkgs.terraform # infrastructure as code tool
        pkgs.tmux # terminal multiplexer
        pkgs.yq-go # jq - but for yaml
        pkgs.nur.repos.Alxandr.gitbutler-cli # git plexer
        pkgs.shfmt # shell script formatter
        pkgs.nur.repos.Alxandr.dagger # dag-based container build tool

        # dotnet
        dotnet

        # altinn specific
        pkgs.nur.repos.Alxandr.altinn-repoctl
      ];

      home.sessionVariables = {
        CONTEXT7_API_KEY = "$(cat ${nixosConfig.sops.secrets."mcp/context7/key".path})";
        MCP_GITHUB_PAT = "$(cat ${nixosConfig.sops.secrets."mcp/github/pat".path})";
      };

      home.sessionVariableFiles = [
        nixosConfig.sops.secrets."altinn.env".path
      ];
    };
}
