My nix computer setups.

# Setting up a new computer

1. Download the latest version of [nixos](https://nixos.org/) and boot it on the target device.
2. Exit GUI installer and open a terminal.
3. Set `$EDITOR` to `vim` using `export EDITOR=vim`.
4. Add the following to the config:
   `nix.settings.experimental-features = [ "nix-command" "flakes" ];`
5. Switch to new config using `sudo nixos rebuild switch`.