{ lib
, nixpkgs
, disko
, neovim-flake
, home-manager
}:

{
  mkSystem =
    { flake
    , hosts
    , supportedSystems ? [
        "x86_64-linux"
        "aarch64-linux"
        "riscv64-linux"
      ]
    ,
    }@config:
    let
      neovim = import ./neovim.nix { inherit neovim-flake; };
      host = import ./host.nix {
        inherit lib supportedSystems neovim flake home-manager;
        inherit (disko.nixosModules) disko;
      };

      inherit (host) mkHost mkHosts;

      hosts = mkHosts config.hosts;
      forAllSystems = lib.genAttrs supportedSystems;

      hostnames = builtins.attrNames hosts;

      mkSetupPackage = pkgs: name: host:
        let
          setup-package = pkgs.callPackage ../packages/setup-host {
            inherit host flake;
            disko = disko.lib;
          };
        in
        setup-package // { inherit host; };

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (pkgs) lib;

          setup-packages = lib.mapAttrs (mkSetupPackage pkgs) hosts;
          setup-packages' = lib.mapAttrs' (name: pkg: lib.nameValuePair pkg.name pkg) setup-packages;

          install-package = pkgs.callPackage ../packages/install {
            inherit setup-packages;
          };

          packages = setup-packages' // {
            install = install-package;
          };
        in
        packages
      );

      apps = forAllSystems (system:
        let pkgs = packages.${system};
        in
        {
          install = {
            type = "app";
            program = "${pkgs.install}/bin/install";
          };
        }
      );

      nixosConfigurationList = builtins.attrValues (builtins.mapAttrs (name: host: host.nixosConfigurations) hosts);
      nixosConfigurations = lib.foldl lib.mergeAttrs { } nixosConfigurationList;
    in
    {
      inherit nixosConfigurations packages apps;
    };
}
