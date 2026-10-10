# module: shared/sops
# cle age d hote, commune a nixos et nix-darwin.
# mkHost importe le module sops-nix, puis celui-ci.
# pas de sshd : les defauts de sshKeyPaths pointeraient vers
# /etc/ssh/ssh_host_* (darwin les a en dur, meme sans openssh).
{ lib, options, ... }:

{
  # optionalAttrs, pas mkIf : mkIf declare l option meme quand la condition
  # est fausse, et darwin n a pas environment.sessionVariables.
  config = lib.mkMerge [
    {
      # meme chemin sur les 3 hosts : c est l exemple des deux modules sops-nix.
      sops.age.keyFile = "/var/lib/sops-nix/key.txt";
      sops.age.sshKeyPaths = [ ];
      sops.gnupg.sshKeyPaths = [ ];
    }
    # cle utilisateur pour `sops`. $HOME reste literal :
    # pam_env (nixos) le traduit en @{HOME} ; fish (darwin) l expanse au demarrage.
    # nixos : sessionVariables, posees par PAM avant nushell.
    # darwin : environment.variables, source par /etc/fish/nixos-env-preinit.fish.
    (lib.optionalAttrs (options.environment ? sessionVariables) {
      environment.sessionVariables.SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
    })
    (lib.optionalAttrs (!(options.environment ? sessionVariables)) {
      environment.variables.SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
    })
  ];
}
