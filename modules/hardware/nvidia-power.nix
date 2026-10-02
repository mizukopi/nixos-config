# module: hardware/nvidia-power
# limite de puissance de la rtx 4070 : 170 w au lieu de 200 w
# moins de chaleur et de bruit pour une perte de perf quasi nulle
{ config, ... }:

{
  # garde le pilote chargé en permanence, sinon la limite peut être perdue
  hardware.nvidia.nvidiaPersistenced = true;

  # applique la limite à chaque démarrage
  systemd.services.nvidia-power-limit = {
    description = "limite de puissance gpu (170 w)";
    wantedBy = [ "multi-user.target" ];
    after = [ "nvidia-persistenced.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi -pl 170";
    };
  };
}
