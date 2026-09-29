# nixos-config

> [!WARNING]
> this is my **personal** nix configuration, built from scratch as a learning
> project. it is tailored to my own machines and habits, so most of it will not
> work out of the box for you.

three machines share this repo: two nixos hosts and one macbook under
nix-darwin. dotfiles are managed by [hjem](https://github.com/feel-co/hjem) in
symlink-only mode, native config files in `config/` are the single source of
truth, and hjem just links them into place.

## foreword

i'm learning linux and nix in the open. this repo is the practice ground. the
goal is to understand rather than to assemble the flashiest setup, so things are
kept deliberately small and explicit. if a choice looks naive, it probably
reflects where i was in the learning curve when i made it.

## hosts

| name | machine | platform | gpu | role |
|---|---|---|---|---|
| `navi` | thinkpad x1 carbon gen 12 (meteor lake) | nixos | intel arc (integrated) | learning machine, laptop |
| `games` | asus tuf gaming h770-pro, i7-13700kf | nixos | nvidia rtx 4070 | desktop, gaming |
| `sommei` | macbook pro (m1 pro) | nix-darwin (`aarch64-darwin`) | — | multimedia daily driver |

the main per-host differences:

- **navi** enables power management and ships `powertop`. its hidpi panel runs at
  hyprland scale 1.8.
- **games** pulls the nvidia proprietary driver (closed module, stable branch),
  steam with proton-ge, coolercontrol with the `nct6775` kernel module, and
  spicetify. its monitor is forced to `2560x1440@360` at scale 1.07.
- on both nixos hosts, **wayle** (the status bar) reads a different
  `runtime.toml`, selected through a custom module option
  (`fyrr.wayle.runtimeFile`) declared in `modules/desktop/hjem.nix`.
- **sommei** runs macos. nix-darwin handles the declarative system config, and
  homebrew — itself installed and pinned by nix-homebrew — covers the gui casks
  that nix handles poorly on mac.

## structure

```
nixos-config/
├── flake.nix              # inputs + declares navi, games, sommei
├── flake.lock
├── justfile               # task runner: switch, build, fmt, lint, check, update
├── theme.nix              # colour palette, single source for the whole theme
├── treefmt.nix            # formatter config (nixfmt)
├── statix.toml            # linter exclusions
├── hosts/
│   ├── navi/{default,hardware}.nix
│   ├── games/{default,hardware}.nix
│   └── sommei/default.nix
├── modules/
│   ├── core/              # boot, locale, networking, nix daemon, users
│   ├── desktop/           # hyprland, sddm, audio, fonts, cursor, printing, hjem
│   ├── hardware/          # intel, nvidia, bluetooth
│   └── programs/          # cli, apps, office, gaming, spicetify
└── config/                # native dotfiles (hyprland.lua, kitty.conf, ...)
```

modules are opt-in: each host imports only what it needs. `modules/desktop`
groups the shared graphical stack for the nixos hosts, while
`modules/desktop/hjem.nix` declares their dotfile symlinks. the darwin host
declares its own hjem block inline, since its paths and its subset of tools
differ.

## flake inputs

| input | purpose |
|---|---|
| `nixpkgs` | unstable channel |
| `nix-darwin` | macos system management for `sommei` |
| `hjem` | dotfile symlinks |
| `nix-homebrew` | installs and pins homebrew itself on `sommei` |
| `spicetify-nix` | patched spotify on `games` |
| `treefmt-nix` | formatter + `nix flake check` gate |

all inputs follow the same `nixpkgs`, so there is only one nixpkgs in the
closure.

## theming

`theme.nix` sits at the repo root and holds two palettes, `blood` (default) and
`copland` — a serial experiments lain reference. a single `variant` string picks
one. both palettes expose the same 26 semantic keys (catppuccin convention) plus
the 16 ansi colours, so any consumer that interpolates `theme.palette.<key>`
rethemes automatically.

the file is imported once in `flake.nix` and threaded to every host through
`specialArgs` as `theme`. `wezterm.lua` is generated from it with
`pkgs.writeText`, so no colour is hardcoded there. other tools (kitty, rofi,
spicetify) still carry their own static theme files — migrating them is on the
list.

## daily workflow

`just` is the entry point. run it with no argument to list the recipes.

```sh
just switch    # rebuild + activate this host
just build     # build only, no activation
just fmt       # run nixfmt over every .nix file (writes)
just lint      # statix + deadnix
just check     # format check + lint, mirrors what ci should do
just update    # nix flake update
```

the recipes detect the platform with `uname` and the machine name on their own,
so the same command works on all three hosts. `switch` and `build` use
`justfile_directory()`, so they work from any subdirectory.

order matters: **`fmt` corrects, `check` only verifies.** `check` builds a
derivation that formats a copy of the sources in the nix sandbox and fails on
any diff — it can never write to the repo. so the loop is:

```
edit → just fmt → just check → commit → just switch
```

### rebuilding by hand

```sh
# nixos (navi, games)
sudo nixos-rebuild switch --flake .#<hostname>

# darwin (sommei)
sudo darwin-rebuild switch --flake .#sommei
```

on macos the flake attribute must match `scutil --get LocalHostName`, not the
output of `hostname` — that one can be overwritten by dhcp or mdns.

### development shell

```sh
nix develop
```

gives `nixd` (language server), `nixfmt`, `statix`, `deadnix` and `just` without
installing them system-wide.

## gotchas

- **flakes only see git-tracked files.** after creating a file, `git add` before
  rebuilding — including any new source referenced from the config, or nix fails
  with `Path '...' does not exist in the Git repository`.
- **hjem links point into the nix store**, not into the live repo. editing a
  dotfile and reloading the tool is not enough; the change only lands after a
  rebuild.
- **hjem links files, not directories**, so it does not clobber things like
  fish's `conf.d/` or `functions/`.
- **bootstrapping a tool that drives rebuilds** is circular: adding `just` to a
  host's packages does nothing until a rebuild has run, and the rebuild is what
  `just` was supposed to launch. break the loop once by hand, or with
  `nix run nixpkgs#just -- switch`.
- **zen (browser) rewrites its own `profiles.ini`**, so it cannot be symlinked
  from the read-only store. an idempotent activation script on `sommei` seeds it
  once with a fixed profile directory name, otherwise zen picks eight random
  characters and the declared `user.js` points nowhere.
- **`homebrew.onActivation.cleanup = "uninstall"`** removes any cask that is not
  in the declared list. brew now prints a deprecation warning for the underlying
  flag.

## desktop (nixos hosts)

- display manager: sddm, hyprland as default session
- terminal: wezterm
- shell: nushell (login shell), starship prompt

`mainMod` is bound to `ALT` rather than `SUPER`

## system

- network: networkmanager, tailscale (firewall opened for it), mullvad
- printing: cups
- automatic nix garbage collection, weekly, older than 7 days
- store auto-optimisation
- locale: `en_US.UTF-8` with french regional settings, timezone `Europe/Paris`
- `sommei`: touch id for sudo, declarative dock / finder / trackpad / keyboard
  repeat / screenshot settings

## known gaps

- **no secrets management.** `recipents.txt` (note the typo) holds an orphan age
  public key from an abandoned sops-nix attempt. sops-nix is the intended fix.
- **no ci committed.** `just check` describes itself as mirroring ci, but no
  workflow exists in the repo yet.
- **`just check` does not build the hosts**, it only checks formatting and
  lints. a broken host config passes.
- **theming is only half declarative.** kitty, rofi and spicetify still carry
  hand-written colour files instead of reading `theme.nix`.
- **git identity is not declared** anywhere in the config, and the history
  carries several author names.
