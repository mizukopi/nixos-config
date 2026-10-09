# grok-bot : client bureau (hors nixpkgs). appimage stable epingle.
# le store est en lecture seule : l auto-update interne ne s applique pas,
# une nouvelle version se fait en bumpant version et hash.
{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "grok-bot";
  version = "0.68.1";
  # feed stable linux-x64 : commitSha 33103062f95061ccf9c81c5b365d37ab152c3b66
  src = fetchurl {
    url = "https://downloads.cursor.com/grokbot/stable/33103062f95061ccf9c81c5b365d37ab152c3b66/linux/x64/Grok_Bot_0.68.1.AppImage";
    hash = "sha256-L+fFrOzM1VehM7DGGSmX7AwTIPHp/Hvv/MprXozvuls=";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/grok-bot.desktop $out/share/applications/grok-bot.desktop
    substituteInPlace $out/share/applications/grok-bot.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=grok-bot'
    mkdir -p $out/share/icons
    cp -r ${appimageContents}/usr/share/icons/hicolor $out/share/icons/
  '';

  meta = {
    description = "Desktop client for Grok Bot";
    homepage = "https://cursor.com/download/bot";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "grok-bot";
  };
}
