# module: core/networking
# networkmanager + tailscale + mullvad + firewall rules
{ config, ... }:

{
  networking.networkmanager.enable = true;

  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.gui.enable = true;
  services.resolved.enable = true;

  services.tailscale.enable = true;

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
