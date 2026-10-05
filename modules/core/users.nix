# module: core/users
# user paul + nushell
{ pkgs, ... }:

{
  users.users.paul = {
    isNormalUser = true;
    description = "paul";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.nushell;
  };

  # nushell dans /etc/shells (liste des shells de connexion autorises)
  environment.shells = [ pkgs.nushell ];

}
