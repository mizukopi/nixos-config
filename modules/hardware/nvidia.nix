# module: hardware/nvidia
# proprietary nvidia drivers for the rtx 4070 on games
{ config, ... }:

{
  # enables graphics acceleration (replaces the old hardware.opengl.enable)
  hardware.graphics.enable = true;

  # declares nvidia as video driver, required even under wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # required for wayland (hyprland)
    modesetting.enable = true;

    # laptop options, disabled on a desktop running on AC power
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # module noyau open : recommande par nvidia depuis la branche 560 pour turing
    # et plus recent (rtx 4070 = ada). le userspace reste proprietaire
    open = true;

    # nvidia-settings gui to tune fans, clocks, etc.
    nvidiaSettings = true;

    # pin to the stable driver branch
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
