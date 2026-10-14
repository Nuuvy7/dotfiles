# dotfiles — NixOS Template

A reproducible, flake-based NixOS 26.05 configuration featuring Hyprland, Serpantinum, and declarative application configs. Designed to be cloned and rebuilt on a new machine with minimal setup.

## Contents

```
nixos/
├── flake.nix                    # Flake inputs (nixpkgs, home-manager, serpantinum, qylock, fetch, zen)
├── flake.lock
├── assets/
│   └── dream-journey-cursor/    # Cursor theme (XCursor + Hyprcursor)
└── config/
    ├── configuration.nix        # System configuration (packages, services, Hyprland, databases)
    ├── hardware-configuration.nix # Generated per machine — never committed
    └── home.nix                 # Home Manager (serpantinum, zen, zed, npm)

config/
├── fish/config.fish             # Shell configuration
├── zed/                         # Editor settings
├── serpantinum/settings.json    # Wayland shell
├── hypr/hyprland.conf           # Window manager
├── kitty/kitty.conf             # Terminal
├── micro/settings.json          # Text editor
└── btop/btop.conf               # System monitor

install.sh                       # Symlinks application configs to ~/.config/
```

## Setting Up a New Machine

### Prerequisites

- A bootable NixOS live ISO
- Active internet connection
- Git available (via `nix-shell -p git` if needed)

### 1. Clone the repository

```bash
git clone https://github.com/Nuuvy7/dotfiles ~/dotfiles
cd ~/dotfiles
```

### 2. Generate hardware configuration

The tracked `hardware-configuration.nix` belongs to another machine. Generate your own:

```bash
# Inspect your disks first
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT

sudo nixos-generate-config --show-hardware-config > nixos/config/hardware-configuration.nix
```

### 3. Set hostname and username

Edit the `let` block in `nixos/flake.nix`:

```nix
let
  hostname = "your-hostname";   # e.g. "laptop-alex"
  username = "your-username";   # e.g. "alex"
in
```

### 4. Remove the machine-specific NTFS mount

`configuration.nix` includes a mount entry for a disk that only exists on the original machine. Delete the following block:

```nix
fileSystems."/home/${username}/deta" = { ... };
```

### 5. Symlink application configs

```bash
./install.sh
```

### 6. Rebuild

```bash
cd nixos
sudo nixos-rebuild switch --flake .#windflower
```

### 7. Reboot

```bash
sudo reboot
```

## Daily Workflow

### Editing configurations

All edits are made inside the repository. The `install.sh` symlinks mean changes to files under `config/` apply immediately; changes to `.nix` files require a rebuild.

```bash
cd ~/dotfiles
# Edit nixos/config/home.nix, config/hypr/hyprland.conf, etc.
git add -A && git commit -m "feat: add package X"
git push
```

### Rebuilding

```bash
cd ~/dotfiles/nixos
sudo nixos-rebuild switch --flake .#windflower
```

### Updating inputs

```bash
cd ~/dotfiles/nixos
nix flake update
sudo nixos-rebuild switch --flake .#windflower
```

## Customization

| What | Where | How |
|---|---|---|
| Hostname | `flake.nix` let block | Edit directly |
| Username | `flake.nix` let block | Edit directly |
| System packages | `config/configuration.nix` systemPackages | Edit directly |
| User packages | `config/home.nix` home.packages | Edit directly |
| Application configs | `config/` | Edit directly, symlinked on next login |
| NTFS disk mount | `config/configuration.nix` fileSystems | Remove if the disk is not present |

## Included Components

- Hyprland with UWSM and Wayland portals
- Serpantinum shell (Quickshell-based) with matugen color sync
- SDDM with Qylock theme
- Zen Browser as default browser
- Zed editor, Fish shell, Kitty terminal
- MySQL, PostgreSQL, and DBeaver for database work
- Apache, PHP-FPM, and Adminer as a local web stack
- A curated set of security and CTF tools

## Notes

- `hardware-configuration.nix` is not tracked in git; it must be generated per machine because disk UUIDs differ.
- Secret files (`.env`, `auth.json`, credential files) are gitignored and must be set up manually on each machine.
- The first rebuild takes roughly 15 minutes while packages are downloaded and compiled.
- Application configs in `config/` are symlinked into `~/.config/` by `install.sh`; edit them in the repository, not in the symlink targets.
