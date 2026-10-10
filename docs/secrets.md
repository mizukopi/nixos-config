# Secrets (sops-nix)

Les secrets ne vont pas dans le dépôt en clair. [sops-nix](https://github.com/Mic92/sops-nix) les chiffre avec [sops](https://github.com/getsops/sops) et age. Le fichier chiffré (`secrets/*.yaml`) peut être commité ; seule une clé privée age correspondante peut le lire.

Le module est branché sur les trois hôtes : `navi` et `games` (`nixosModules.sops`) et `sommei` (`darwinModules.sops`). La configuration (clé d'hôte, pas de clés SSH) est dans `modules/shared/sops.nix`. Aucun secret n'est déclaré, et `sops.defaultSopsFile` n'est pas fixé : l'évaluation passe sans fichier chiffré. Le shell de dev (`nix develop`) fournit `sops` et `age`.

Ces machines n'ont pas sshd. sops-nix ne doit pas chercher de clé d'hôte SSH : `sops.age.sshKeyPaths` et `sops.gnupg.sshKeyPaths` sont vides. Chaque hôte a sa propre clé age.

## Clé d'hôte

Une clé par machine, hors du dépôt, lisible seulement par root. Le chemin est `sops.age.keyFile`, le même sur les trois hôtes : c'est l'exemple du module darwin comme du module NixOS.

```sh
sudo mkdir -p /var/lib/sops-nix
sudo age-keygen -o /var/lib/sops-nix/key.txt
sudo chmod 600 /var/lib/sops-nix/key.txt
sudo age-keygen -y /var/lib/sops-nix/key.txt
```

`age-keygen -y` affiche la clé publique (`age1...`). La coller dans `.sops.yaml` à la place du `TODO` de l'hôte (`navi`, `games` ou `sommei`). Ne jamais commiter `key.txt`.

`sops.age.generateKey` reste désactivé : la clé n'est pas créée au switch.

## Clé utilisateur

Elle sert à éditer les secrets, pas à les déchiffrer sur la machine.

```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
```

Coller la clé publique à la place de `TODO_USER` dans `.sops.yaml`. Sauvegarder `keys.txt` hors de la machine : sans elle, un secret n'est récupérable que si une clé d'hôte destinataire existe encore.

`SOPS_AGE_KEY_FILE` vaut `~/.config/sops/age/keys.txt` pour la session de l'utilisateur, sans export manuel. Sur NixOS c'est `environment.sessionVariables` : PAM la pose avant le shell, donc nushell la voit. Sur darwin c'est `environment.variables`, sourcé par fish au démarrage (`/etc/fish/nixos-env-preinit.fish`). sops ne tombe donc pas sur `~/Library/Application Support/sops/age/keys.txt`.

## Éditer un secret

`.sops.yaml` chiffre tout fichier qui matche `secrets/*.yaml` pour l'utilisateur et les trois hôtes. Remplacer les `TODO` avant le premier appel, sinon sops refuse le destinataire.

```sh
sops secrets/foo.yaml
```

Depuis la racine. sops ouvre le clair dans `$EDITOR`. Ajouter le fichier à git.

## S'en servir dans un module

```nix
{ config, ... }:
{
  sops.secrets."foo".sopsFile = ../../secrets/foo.yaml;

  # fichier déchiffré, par défaut /run/secrets/foo
  services.example.passwordFile = config.sops.secrets."foo".path;
}
```

`config.sops.secrets."foo".path` est le chemin à passer à une option qui attend un fichier. Le contenu n'est pas dans le store.

## Ajouter un destinataire

Après avoir ajouté une clé publique dans `.sops.yaml` :

```sh
sops updatekeys secrets/foo.yaml
```

sops réécrit le fichier pour les destinataires de la règle. Il faut encore une clé privée qui déchiffre la version actuelle.

## Si le secret est déclaré avant la clé

Déclarer `sops.secrets."foo"` alors que `/var/lib/sops-nix/key.txt` n'existe pas encore, ou que sa clé publique n'est pas destinataire du fichier, fait échouer l'activation : `sops-install-secrets` ne peut pas déchiffrer, le script d'activation s'arrête, et `nixos-rebuild switch` ou `darwin-rebuild switch` ne bascule pas sur cette génération. Créer la clé d'hôte et l'ajouter aux destinataires avant de déclarer le secret.
