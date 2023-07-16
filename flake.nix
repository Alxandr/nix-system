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

    # Official NixOS package source, using nixos's stable branch by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

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

		# generate iso/qcow2/docker/... image from nixos configuration
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

		# secrets management, lock with git commit at 2023/7/15
    agenix.url = "github:ryantm/agenix/0d8c5325fc81daf00532e3e26c6752f7bcde1143";

		# my private secrets, it's a private repository, you need to replace it with your own.
    # use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone to save time
    # mysecrets = { url = "git+ssh://git@github.com/ryan4yin/nix-secrets.git?shallow=1"; flake = false; };
	};

	# The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
	outputs =
		inputs@{ self
    , nixpkgs
    , home-manager
    , nixos-generators
    , ...
    }:

		let
      x64_system = "x86_64-linux";
      x64_specialArgs = {
        # use unstable branch for some packages to get the latest updates
        pkgs-unstable = import inputs.nixpkgs-unstable {
          system = x64_system; # refer the `system` parameter form outer scope recursively
          # To use chrome, we need to allow the installation of non-free software
          config.allowUnfree = true;
        };
      } // inputs;

			# VirtualBox nixos test VM
			host_test_modules = [
				./hosts/nixos-test-vm

				home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = x64_specialArgs;
          # home-manager.users.alxandr = import ./home/linux/x11.nix;
          home-manager.users.alxandr = import ./home/linux/wayland.nix;
        }
			];
		in {
			nixosConfigurations = let system = x64_system; specialArgs = x64_specialArgs; in {
				nixos-test-vm = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = host_test_modules;
        };
			};

			formatter = {
        # format the nix code in this flake
        # alejandra is a nix formatter with a beautiful output
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
      };

			packages.x86_64-linux =
				# take images for hosts
        #   https://github.com/nix-community/nixos-generators
				let system = x64_system; specialArgs = x64_specialArgs; in  {
					# Hoshino Aquamarine is a virtual machine running on VirtualBox.
					nixos-test-vm = nixos-generators.nixosGenerate {
						inherit system specialArgs;
						modules = host_test_modules ++ [
							({config, ...}: {
								proxmox.qemuConf.name = "aquamarine-nixos-${config.system.nixos.label}";
							})
						];

						format = "virtualbox";
					};
				};
		};
}
