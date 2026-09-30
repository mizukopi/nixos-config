# module: programs/apps
# general graphical apps (browser, file manager, media, terminals, editors, chat)
{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    brave
    kdePackages.ark
    kdePackages.dolphin # file manager
    kdePackages.kio # kio plumbing (required)
    kdePackages.kio-extras # extra protocols (sftp, etc.)
    kdePackages.kio-fuse # mount remote filesystems
    kdePackages.breeze-icons # icon theme (avoids blank icons)
    imv
    mpv
    obs-studio
    nushell
    ente-auth
    # zen absent de nixpkgs : flake communautaire (binaire officiel de zen, repackage)
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    gajim
    signal-desktop
    equibop
    kitty
    wezterm
    zed-editor
    kdePackages.kate
    kdePackages.qttools
    kdePackages.kdenlive
  ];

  programs.firefox.enable = true;

  # file type (mime) → default application associations
  xdg.mime.defaultApplications = {
    "image/png" = "imv.desktop";
    "image/jpeg" = "imv.desktop";
    "image/gif" = "imv.desktop";
    "image/webp" = "imv.desktop";
    "image/bmp" = "imv.desktop";
    "image/tiff" = "imv.desktop";
    "image/svg+xml" = "imv.desktop";
    "image/x-icon" = "imv.desktop";
  };
}
