# module: desktop/hyprland
# hyprland + hyprlock + wayland ecosystem packages
{ pkgs, ... }:

{
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;

  # agent polkit (fenetre de mot de passe pour les actions privilegiees), absent par
  # defaut sous hyprland. on rend son unite systemd dispo, lancee depuis hyprland.lua
  systemd.packages = [ pkgs.hyprpolkitagent ];

  environment.systemPackages = with pkgs; [
    rofi
    brightnessctl
    wayle
    hyprshot
    playerctl
  ];
}
