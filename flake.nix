{
	description = "NixOS configuration for my personal systems";

	# the nixConfig here only affects the flake itself, not the system configuration!
	nixConfig = {
		experimental-features = [ "nix-command" "flakes" ];
		trusted-users = [ "alxandr" ];

		substituters = [
      "https://cache.nixos.org"
    ];

		# nix community's cache server
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
	};

	# This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
	inputs = {
		# There are many ways to reference flake inputs. The most widely used is github:owner/name/reference,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

		# disko is used to format the disks of the computers
		disko = {
			url = "github:nix-community/disko";
			# The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
		};

		# home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };

		# modern window compositor
    hyprland.url = "github:hyprwm/Hyprland/v0.27.0";
    # community wayland nixpkgs
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

		# # generate iso/qcow2/docker/... image from nixos configuration
    # nixos-generators = {
    #   url = "github:nix-community/nixos-generators";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

		# # secrets management, lock with git commit at 2023/7/15
    # agenix.url = "github:ryantm/agenix/0d8c5325fc81daf00532e3e26c6752f7bcde1143";

		# # my private secrets, it's a private repository, you need to replace it with your own.
    # # use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone to save time
    # mysecrets = { url = "git+ssh://git@github.com/ryan4yin/nix-secrets.git?shallow=1"; flake = false; };
	};

	outputs = { self, nixpkgs, disko, home-manager, ... }@inputs:
		let
			mkVM = import ./lib/mkvm.nix;

			# Overlays is the list of overlays we want to apply from flake inputs.
    	overlays = [];

		in {
			nixosConfigurations = {
				installer = nixpkgs.lib.nixosSystem rec {
					system = "x86_64-linux";
					modules = [
						/etc/nixos/configuration.nix
					];
				};

				vm-test = mkVM "vm-test" rec {
					inherit nixpkgs home-manager overlays disko;
					system  = "x86_64-linux";
					users   = [ "alxandr" ];
					disko-args = {
						disks   = [ "/dev/sda" ];
						memory  = "8G";
					};
				};
			};

			hosts = builtins.attrNames self.nixosConfigurations;
		};
}
