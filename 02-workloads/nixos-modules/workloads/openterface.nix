{
  workloads-lib,
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  inherit (workloads-lib) mkWorkloadOption mkProgramOption;
  inherit (pkgs.stdenv.hostPlatform) system;

  cfg = config.workloads.openterface;
in
{
  options.workloads.openterface = mkWorkloadOption {
    name = "openterface";
    defaultEnable = false;
    programs = mergeAttrsList ([
      {
        openterface = mkProgramOption {
          inherit pkgs;
          name = "openterface";
          package = "openterface-qt";
        };
      }
    ]);
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.programs.openterface.enable {
      environment.systemPackages = [ cfg.programs.openterface.package ];

      # The package supplies rules for the standard Mini-KVM interfaces:
      # 1a86:7523 (ttyUSB) and 534d:2109 (hidraw).
      services.udev.packages = [ cfg.programs.openterface.package ];

      services.udev.extraRules = ''
        # The package rule tags this node with uaccess.  Keep a group-based
        # fallback because the application also supports sessions without ACLs.
        KERNEL=="hidraw*", ATTRS{idVendor}=="534d", ATTRS{idProduct}=="2109", GROUP="dialout", MODE="0660"

        SUBSYSTEM=="usb", ATTRS{idVendor}=="345f", ATTRS{idProduct}=="2109", TAG+="uaccess"
        KERNEL=="hidraw*", ATTRS{idVendor}=="345f", ATTRS{idProduct}=="2109", GROUP="dialout", MODE="0660"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="345f", ATTRS{idProduct}=="2132", TAG+="uaccess"
        KERNEL=="hidraw*", ATTRS{idVendor}=="345f", ATTRS{idProduct}=="2132", GROUP="dialout", MODE="0660"

        SUBSYSTEM=="tty", KERNEL=="ttyACM[0-9]*", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="fe0c", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="fe0c", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55e0", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="4348", ATTRS{idProduct}=="55e0", TAG+="uaccess"
      '';
    })
  ]);
}

# # Add user to dialout group for serial access, and video group for camera access
#  sudo usermod -a -G dialout,video $USER

# #Add udev rules for Openterface Mini-KVM
# echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="534d", ATTRS{idProduct}=="2109", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/51-openterface.rules
# echo 'SUBSYSTEM=="hidraw", ATTRS{idVendor}=="534d", ATTRS{idProduct}=="2109", TAG+="uaccess"' | sudo tee -a /etc/udev/rules.d/51-openterface.rules
# echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="345f", ATTRS{idProduct}=="2109", TAG+="uaccess"' | sudo tee -a /etc/udev/rules.d/51-openterface.rules
# echo 'SUBSYSTEM=="hidraw", ATTRS{idVendor}=="345f", ATTRS{idProduct}=="2109", TAG+="uaccess"' | sudo tee -a /etc/udev/rules.d/51-openterface.rules
# echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="345f", ATTRS{idProduct}=="2132", TAG+="uaccess"' | sudo tee -a /etc/udev/rules.d/51-openterface.rules
# echo 'SUBSYSTEM=="hidraw", ATTRS{idVendor}=="345f", ATTRS{idProduct}=="2132", TAG+="uaccess"' | sudo tee -a /etc/udev/rules.d/51-openterface.rules
# echo 'SUBSYSTEM=="ttyUSB", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"' | sudo tee -a /etc/udev/rules.d/51-openterface.rules
# echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"' | sudo tee -a /etc/udev/rules.d/51-openterface.rules
# echo 'SUBSYSTEM=="ttyACM", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="fe0c", TAG+="uaccess"' | sudo tee -a /etc/udev/rules.d/51-openterface.rules
# echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="fe0c", TAG+="uaccess"' | sudo tee -a /etc/udev/rules.d/51-openterface.rules
# sudo udevadm control --reload-rules
# sudo udevadm trigger
