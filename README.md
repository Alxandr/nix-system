My nix computer setups.

# Setting up a new computer

1. Download the latest version of [nixos](https://nixos.org/) and boot it on the target device.
2. Exit GUI installer and open a terminal.
3. Set `$EDITOR` to `vim` using `export EDITOR=vim`.
4. Add the following to the config (using `sudoedit /etc/nixos/configuration.nix`):

   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   environment.systemPackages = [ pkgs.just pkgs.git pkgs.openssl ];

   ```

5. Switch to new config using `sudo nixos rebuild switch`.
6. Git clone this repository: `git clone https://github.com/Alxandr/nix-system`.
