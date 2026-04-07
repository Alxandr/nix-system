{
  yoloproj,
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
      programs.mcp.enable = true;
      programs.mcp.servers = {
        glider = {
          command = "${lib.getExe yoloprojPkgs.glider}";
          args = [
            "--transport"
            "stdio"
          ];
        };

        nuget = {
          command = "${lib.getExe yoloprojPkgs.nuget-mcp-server}";
        };

        github = {
          url = "https://api.githubcopilot.com/mcp/";
          headers = {
            "X-MCP-Toolsets" = "context,repos,issues,users,projects,pull_requests,labels";
          };
        };
      };

      home.packages = [
        # yoloproj packages
        yoloprojPkgs.glider
        yoloprojPkgs.nuget-mcp-server
        yoloprojPkgs.t3code

        # upstream packages
        pkgs.opencode
        pkgs.codex
        pkgs.prek
        pkgs.docker-compose
        pkgs.tmux
        pkgs.pnpm
        pkgs.jq
        pkgs.gh
        pkgs.just
        pkgs.powershell
        pkgs.bun

        # dotnet
        dotnet
      ];
    };
}
