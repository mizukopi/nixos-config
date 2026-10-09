{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nix-darwin.follows = "nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # pas de follows ici : le cache kopuz.cachix.org ne contient que les binaires
    # construits avec leur nixpkgs. suivre le notre = tout recompiler en local
    kopuz.url = "github:Kopuz-org/kopuz";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      hjem,
      nix-darwin,
      nix-homebrew,
      treefmt-nix,
      ...
    }:
    let
      theme = import ./theme.nix;
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      treefmtEval = forAllSystems (
        system: treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix
      );
      # seul specialArgs est commun aux 3 hosts. les modules supplementaires
      # (hjem nixos vs darwin, nix-homebrew) restent passes par l appelant.
      mkHost =
        {
          builder,
          modules,
        }:
        builder {
          specialArgs = {
            inherit inputs theme;
          };
          inherit modules;
        };
    in
    {
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            name = "nixos-config";
            packages = with pkgs; [
              nixd
              nixfmt
              statix
              deadnix
              just
            ];
          };
        }
      );

      nixosConfigurations = {
        navi = mkHost {
          builder = nixpkgs.lib.nixosSystem;
          modules = [
            ./hosts/navi/default.nix
            hjem.nixosModules.default
          ];
        };
        games = mkHost {
          builder = nixpkgs.lib.nixosSystem;
          modules = [
            ./hosts/games/default.nix
            hjem.nixosModules.default
          ];
        };
      };

      darwinConfigurations.sommei = mkHost {
        builder = nix-darwin.lib.darwinSystem;
        modules = [
          ./hosts/sommei/default.nix
          hjem.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew
        ];
      };

    };
}
