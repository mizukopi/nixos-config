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
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

      nixosConfigurations.navi = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs theme; };
        modules = [
          ./hosts/navi/default.nix
          hjem.nixosModules.default
        ];
      };

      nixosConfigurations.games = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs theme; };
        modules = [
          ./hosts/games/default.nix
          hjem.nixosModules.default
        ];
      };

      darwinConfigurations.sommei = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs theme; };
        modules = [
          ./hosts/sommei/default.nix
          hjem.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew
        ];
      };

    };
}
