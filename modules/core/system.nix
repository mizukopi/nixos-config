# module: core/system
# boot, locale, nix daemon, shared packages, firefox
{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
    persistent = true;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  nixpkgs.config.allowUnfree = true;

  # swap compressé en ram (zram) : filet de sécurité quand la ram est pleine, zéro écriture disque
  zramSwap.enable = true;

  programs.firefox.enable = true;

  # mounts removable drives (usb sticks); not enabled outside plasma, so i enable it explicitly
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    fastfetch
    gajim
    equibop
    git
    unzip
    kitty
    wezterm
    zed-editor
    claude-code
    starship
    kdePackages.kate
    kdePackages.qttools
  ];
}
