# module: core
# groups shared system modules for every hosts
{ ... }:

{
  imports = [
    ../shared/nix.nix
    ./system.nix
    ./networking.nix
    ./users.nix
  ];
}
