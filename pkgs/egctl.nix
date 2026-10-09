# egctl : controle des souris endgame gear (hors nixpkgs)
{
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  udev,
}:

rustPlatform.buildRustPackage {
  pname = "egctl";
  version = "0-unstable-2026-07-04";
  src = fetchFromGitHub {
    owner = "Creationsss";
    repo = "egctl";
    rev = "58c9ff6a436ea770f0fdf83ddf566898b97638fb";
    hash = "sha256-iP80W5+8i3xWdLpmmbsHdTgEKs887g7nFIWoN2O4VMU=";
  };
  cargoHash = "sha256-J5Qqzl/LfY4wS4aJFTRlvS6A0sM9d6KdJOVBcmig9xs=";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];
}
