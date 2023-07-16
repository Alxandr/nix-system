{ disks, memory, ... }:
let
	# ESP partition (EFI boot)
	esp_partition = {
		name = "ESP";
		start = "1MiB";
		end = "550MiB";
		bootable = true;
		content = {
			type = "filesystem";
			format = "vfat";
			mountpoint = "/boot";
			mountOptions = [
				"defaults"
			];
		};
	};

	# BTRFS content (subvolume layout)
	btrfs_content = {
		type = "btrfs";
		extraArgs = [ "-f" ]; # Override existing partition
		subvolumes = {
			# Subvolume name is different from mountpoint
			"/@root" = {
				mountpoint = "/";
			};
			"/@home" = {
				mountpoint = "/home";
				mountOptions = [ "compress=zstd" ];
			};
			"/@nix" = {
				mountpoint = "/nix";
				mountOptions = [ "compress=zstd" "noatime" ];
			};
			"@swap" = {
				mountpoint = "/.swapvol";
			};
		};

		postCreateHook = ''
			mount -t btrfs /dev/mapper/crypted -o subvol=@swap /mnt
			btrfs filesystem mkswapfile --size ${memory} /mnt/swap/swapfile
			umount /mnt
		'';
	};

	# Luks encrypted partition
	luks_partition = {
		name = "luks";
		start = "550MiB";
		end = "100%";
		content = {
			type = "luks";
			name = "crypted";
			extraOpenArgs = [ "--allow-discards" ];
			# if you want to use the key for interactive login be sure there is no trailing newline
			# for example use `echo -n "password" > /tmp/secret.key`
			settings.keyFile = "/tmp/secret.key";
			content = btrfs_content;
		};
	};

in
	{
		disko.devices = {
			disk = {
				vdb = {
					type = "disk";
					device = builtins.elemAt disks 0;
					content = {
						type = "table";
						format = "gpt";
						partitions = [
							esp_partition
							luks_partition
						];
					};
				};
			};
		};
	}
