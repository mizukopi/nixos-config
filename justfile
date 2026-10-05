# nixos-config. `just` pour lister.
flake := justfile_directory()

# liste les recettes
default:
    @just --list

# rebuild + switch ce host
switch:
    @if [ "$(uname)" = "Darwin" ]; then \
        sudo darwin-rebuild switch --flake {{flake}}#$(scutil --get LocalHostName); \
    else \
        sudo nixos-rebuild switch --flake {{flake}}#$(hostname); \
    fi

# build seul, pas d'activation
build:
    @if [ "$(uname)" = "Darwin" ]; then \
        darwin-rebuild build --flake {{flake}}#$(scutil --get LocalHostName); \
    else \
        nixos-rebuild build --flake {{flake}}#$(hostname); \
    fi

# formate tous les fichiers nix
fmt:
    nix fmt

# statix + deadnix, épinglés au nixpkgs du lock (--inputs-from garantit que
# local et CI lancent la même version des linters)
lint:
    nix run --inputs-from {{flake}} nixpkgs#statix -- check .
    nix run --inputs-from {{flake}} nixpkgs#deadnix -- --fail .

# gate local : format + lint. miroir exact de ce que fait la CI.
check:
    nix build --no-link {{flake}}#checks.$(nix eval --impure --raw --expr 'builtins.currentSystem').formatting
    just lint
    just eval

# évalue les 3 hosts sans rien construire : attrape options inexistantes et fautes de frappe
eval:
    nix eval {{flake}}#nixosConfigurations.navi.config.system.build.toplevel.drvPath
    nix eval {{flake}}#nixosConfigurations.games.config.system.build.toplevel.drvPath
    nix eval {{flake}}#darwinConfigurations.sommei.config.system.build.toplevel.drvPath

# met à jour tous les inputs
update:
    nix flake update
