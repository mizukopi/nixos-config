# module: shared/sops
# cle age d hote, commune a nixos et nix-darwin.
# mkHost importe le module sops-nix, puis celui-ci.
# pas de sshd : les defauts de sshKeyPaths pointeraient vers
# /etc/ssh/ssh_host_* (darwin les a en dur, meme sans openssh).
{ ... }:

{
  # meme chemin sur les 3 hosts : c est l exemple des deux modules sops-nix.
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];
}
