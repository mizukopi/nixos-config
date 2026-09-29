# module: desktop/sddm
# display server + sddm + us keyboard layout
{ lib, ... }:

{
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "hyprland";

  services.xserver.xkb = {
    layout = lib.mkDefault "us"; # games le remplace par "fr"
    variant = "";
  };
}
