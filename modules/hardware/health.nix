# module: hardware/health
# surveillance matérielle : santé des ssd (smart), capteurs, test de ram au boot
{ pkgs, ... }:

{
  # smartd surveille les disques en tâche de fond et alerte (wall) en cas de dégradation
  services.smartd.enable = true;

  # ajoute une entrée memtest86+ au menu systemd-boot (test de ram ponctuel)
  boot.loader.systemd-boot.memtest86.enable = true;

  environment.systemPackages = with pkgs; [
    smartmontools # smartctl : usure et erreurs des ssd
    lm_sensors # sensors : températures cpu/carte mère
    nvme-cli # infos détaillées nvme
  ];
}
