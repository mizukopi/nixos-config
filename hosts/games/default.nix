# host: games
# desktop pc — gaming/multimedia
{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ../../modules/core
    ../../modules/desktop
    ../../modules/desktop/hjem.nix
    ../../modules/hardware/nvidia.nix
    ../../modules/hardware/health.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/programs/cli.nix
    ../../modules/programs/gaming.nix
    ../../modules/programs/office.nix
    ../../modules/programs/apps.nix
    ../../modules/programs/spicetify.nix
  ];

  networking.hostName = "games";
  console.keyMap = "fr";
  # dual boot : la rtc reste en utc. côté windows, clé registre RealTimeIsUniversal = 1
  services.xserver.xkb.layout = "fr";
  fyrr.wayle.configFile = ../../config/wayle/config-games.toml;

  boot.kernelModules = [ "nct6775" ];

  programs.coolercontrol.enable = true;

  system.stateVersion = "25.11";
  environment.systemPackages = with pkgs; [
    (rustPlatform.buildRustPackage {
      pname = "egctl";
      version = "unstable";
      src = fetchFromGitHub {
        owner = "Creationsss";
        repo = "egctl";
        rev = "58c9ff6a436ea770f0fdf83ddf566898b97638fb";
        hash = "sha256-iP80W5+8i3xWdLpmmbsHdTgEKs887g7nFIWoN2O4VMU=";
      };
      cargoHash = "sha256-J5Qqzl/LfY4wS4aJFTRlvS6A0sM9d6KdJOVBcmig9xs=";
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ udev ];
    })
  ];
}
