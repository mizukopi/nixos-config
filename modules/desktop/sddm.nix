# module: desktop/sddm
# sddm en wayland (session hyprland) + xserver pour le clavier et nvidia
{ lib, ... }:

{
  # greeter wayland (weston, le defaut du module). weston lit services.xserver.xkb
  # pour le layout. on garde xserver.enable : videoDrivers nvidia en depend, et
  # le module nvidia ne charge nvidia/nvidia_modeset/nvidia_drm que si xserver est actif.
  services.displayManager.sddm.wayland.enable = true;

  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.settings.General.Numlock = "on"; # verr num actif sur sddm aussi
  services.displayManager.defaultSession = "hyprland";

  services.xserver.xkb = {
    layout = lib.mkDefault "us"; # games le remplace par "fr"
    variant = "";
  };
}
