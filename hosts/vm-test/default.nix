{ config, pkgs, ... } @ args:

#############################################################
#
#  Test VM to test nixos
#
#############################################################

{
	imports = [
		# Include the results of the hardware scan.
		./hardware-configuration.nix

		../../modules/nixos/core/desktop.nix
		../../modules/nixos/user-group.nix
	];

	# Virtualbox guest addons
  virtualisation.virtualbox.guest.enable = true;

	# Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel modules
  boot.kernelModules = [ "kvm" ];

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

	# Enable swap on luks
  boot.initrd.luks.devices."luks-8ca65472-cd20-46e9-a4d6-3c42b414096e".device = "/dev/disk/by-uuid/8ca65472-cd20-46e9-a4d6-3c42b414096e";
  boot.initrd.luks.devices."luks-8ca65472-cd20-46e9-a4d6-3c42b414096e".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
}
