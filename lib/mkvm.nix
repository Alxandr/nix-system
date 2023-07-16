# This function creates a NixOS system based on our VM setup for a
# particular architecture.
name: { nixpkgs, home-manager, system, users, overlays }:

let
	overlay_modules = [
		# Apply our overlays. Overlays are keyed by system type so we have
    # to go through and apply our system type. We do this first so
    # the overlays are available globally.
    { nixpkgs.overlays = overlays; }
	];

	machine_modules = [
    ../hosts/${name}/default.nix
	];

	user_modules = map (user: ../users/${user}/nixos.nix) users;

	home_manager_modules = map (user: home-manager.nixosModules.home-manager {
		home-manager.useGlobalPkgs = true;
		home-manager.useUserPackages = true;
		home-manager.users.${user} = import ../users/${user}/home-manager.nix;
	}) users;

	args_modules = [
		# We expose some extra arguments so that our modules can parameterize
		# better based on these values.
		{
			config._module.args = {
				currentSystemName = name;
				currentSystem = system;
			};
		}
	];

	modules = overlay_modules ++ machine_modules ++ user_modules ++ home_manager_modules ++ args_modules;

in
	nixpkgs.lib.nixosSystem rec {
		inherit system modules;
	}
