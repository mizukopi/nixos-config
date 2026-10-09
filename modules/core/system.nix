# module: core/system
# boot, locale, nix daemon, zram, shared cli packages
{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  # 10 générations max dans le menu de boot : évite de remplir l esp (/boot)
  boot.loader.systemd-boot.configurationLimit = 10;
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

  # dates/persistent : options systemd, retirees sur nix-darwin.
  # automatic et options sont dans modules/shared/nix.nix.
  nix.gc = {
    dates = "weekly";
    persistent = true;
  };

  # auto-optimise-store est volontairement nixos-only : sur darwin l option
  # peut corrompre le store, sommei utilise nix.optimise.automatic a la place.
  # le cache kopuz reste aussi nixos-only (le paquet kopuz de sommei vient de homebrew).
  nix.settings = {
    auto-optimise-store = true;
    # cache binaire de kopuz : telecharge le paquet deja compile au lieu de le
    # compiler (rust, long). la cle verifie que les binaires viennent bien de kopuz
    substituters = [ "https://kopuz.cachix.org" ];
    trusted-public-keys = [
      "kopuz.cachix.org-1:J2X3AnAYhKTJW5S3aCLoA1ckonQXVNZMQvhZA0YAufw="
    ];
  };

  # swap compressé en ram (zram) : filet de sécurité quand la ram est pleine, zéro écriture disque
  zramSwap.enable = true;

  # mounts removable drives (usb sticks); not enabled outside plasma, so i enable it explicitly
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    fastfetch
    git
    unzip
    claude-code
    starship
  ];
}
