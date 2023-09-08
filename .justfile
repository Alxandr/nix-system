# memory        := `grep MemTotal /proc/meminfo | awk '{print $2}'` + "k"

@default:
	# just --list
	#nix run github:nix-community/disko -- --mode disko "{{justfile_directory()}}/disko-config.nix"
