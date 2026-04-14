{
  yoloproj,
  config,
  ...
}:
{
  config.home-manager.users.alxandr =
    { pkgs, lib, ... }:
    let
      yoloprojPkgs = yoloproj.${pkgs.stdenv.hostPlatform.system};
      dotnet =
        let
          combined =
            with pkgs.dotnetCorePackages;
            combinePackages [
              sdk_10_0
              sdk_9_0
              sdk_8_0
            ];

          copied = pkgs.runCommand "dotnet" { } ''
            mkdir -p "$out"/share/dotnet
            cp -aL "${combined}"/share/dotnet/. "$out"/share/dotnet/

            cp -aL "${combined}"/nix-support "$out"/nix-support

            mkdir -p "$out"/bin
            ln -s "$out"/share/dotnet/dotnet "$out"/bin/dotnet
          '';
        in
        copied;

    in
    {
      imports = [
        ./home/worktrunk.nix
      ];

      programs.mcp.enable = true;
      programs.mcp.servers = {
        glider = {
          command = "${lib.getExe pkgs.glider}";
          args = [
            "--transport"
            "stdio"
          ];
        };

        nuget = {
          command = "${lib.getExe pkgs.nuget-mcp-server}";
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

        skills.dotnet = ./skills/dotnet;

        settings = {
          model = "gpt-5.4";
          project_doc_fallback_filenames = [ "CLAUDE.md" ];

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

      # git worktree manager
      programs.worktrunk.enable = true;
      programs.worktrunk.config = {
        post-switch = [
          { direnv = "${lib.getExe pkgs.direnv} allow"; }
          { prek = "${lib.getExe pkgs.prek} install"; }
        ];
      };

      home.packages = [
        pkgs.bun # javascript runtime
        pkgs.docker-compose # docker compose cli
        pkgs.glider # mcp server for .NET
        pkgs.helm # kubernetes package manager
        pkgs.jq # command-line JSON processor
        pkgs.just # command runner for dev tasks
        pkgs.kubectl # kubernetes cli
        pkgs.kubelogin # kubernetes oidc login helper
        pkgs.nuget-mcp-server # mcp server for nuget packages
        pkgs.pnpm # package manager for node
        pkgs.powershell # shell
        pkgs.prek # pre-commit hooks
        pkgs.rtk # cli proxy for reducing LLM token consumption
        pkgs.t3code # ai code multiplexer web ui
        pkgs.terraform # infrastructure as code tool
        pkgs.tmux # terminal multiplexer
        pkgs.yq-go # jq - but for yaml

        # dotnet
        dotnet
      ];

      home.sessionVariables = {
        CONTEXT7_API_KEY = "$(cat ${config.sops.secrets."mcp/context7/key".path})";
        MCP_GITHUB_PAT = "$(cat ${config.sops.secrets."mcp/github/pat".path})";
      };
    };
}
