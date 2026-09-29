# host: navi
# personal thinkpad — intel laptop hardware
{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/core
    ../../modules/desktop
    ../../modules/desktop/hjem.nix
    ../../modules/hardware/intel.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/programs/cli.nix
    ../../modules/programs/office.nix
    ../../modules/programs/apps.nix
  ];

  networking.hostName = "navi";

  fyrr.wayle.configFile = ../../config/wayle/config-navi.toml;

  # laptop power management
  powerManagement.enable = true;

  environment.systemPackages = with pkgs; [
    powertop
  ];

  system.stateVersion = "25.11";
}
