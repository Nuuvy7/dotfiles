# dotfiles — NixOS + Hyprland + Serpantinum

My NixOS configuration with Hyprland, Serpantinum shell, and declarative app configs. Fully reproducible flake-based setup.

## 📦 What's Inside

```
nixos/
├── flake.nix                  # Flake: inputs (nixpkgs, home-manager, serpantinum, etc)
├── flake.lock
├── configuration.nix          # NixOS system (masih ada, legacy)
└── config/
    ├── configuration.nix      # System config (packages, services, dark mode)
    ├── hardware-configuration.nix
    └── home.nix               # Home Manager (serpantinum, zed, zen browser, npm)

config/
├── fish/config.fish           # Shell config
├── zed/                       # Editor settings
├── serpantinum/settings.json  # Wayland shell (bar modules, wallpaper)
├── hypr/hyprland.conf         # WM
├── kitty/kitty.conf           # Terminal
├── micro/settings.json        # Text editor
└── btop/btop.conf             # System monitor
```

## 🚀 Fresh Install

```bash
# 1. Clone the repo
git clone https://github.com/Nuuvy7/dotfiles ~/dotfiles
cd ~/dotfiles

# 2. Link app configs to home directory
chmod +x install.sh
./install.sh

# 3. Edit hardware-configuration.nix for your machine
# Generate: nixos-generate-config --show-hardware-config > nixos/config/hardware-configuration.nix

# 4. Update flake hostname (optional)
# Edit nixos/flake.nix: change "windflower" to your hostname

# 5. Rebuild NixOS from repo
cd nixos
sudo nixos-rebuild switch --flake .#windflower  # or .#your-hostname

# 6. Reboot
sudo reboot
```

## 🔧 Daily Workflow

**Edit configs:**
```bash
cd ~/dotfiles
# Edit nixos/config/home.nix or any app config
git add -A && git commit -m "feat: add package X"
git push
```

**Rebuild system:**
```bash
cd ~/dotfiles/nixos
sudo nixos-rebuild switch --flake .#windflower
```

**Update inputs (nixpkgs, home-manager, etc):**
```bash
cd ~/dotfiles/nixos
nix flake update
sudo nixos-rebuild switch --flake .#windflower
```

## ⚙️ Features

- **Serpantinum 2.2.6** — Wayland shell/bar with quickshell modules and matugen color sync (auto-install via flake)
- **Zen Browser** — Default browser
- **Zed Editor** — Custom settings and keybindings ([extension recommendations](ZED_EXTENSIONS.md))
- **Dream Journey Cursor** — XCursor + Hyprcursor theme (auto-install via flake)
- **TUI color sync** — btop, micro, nvim, and kitty automatically follow Serpantinum colors
- **Qylock** — Lockscreen theme available in flake (opt-in, not enabled by default)

## 📝 Notes

- **`hardware-configuration.nix` is tracked** (machine-specific but needed for bootstrap; edit manually if hardware changes)
- **Secret files** (`.env`, `auth.json`, `*credentials*`, `*.token`) are gitignored — set them up manually per machine
- **First rebuild** takes ~15 minutes (download + compile Nix packages)
- **Symlinked configs** — app configs in `~/dotfiles/config/` are symlinked to `~/.config/` (edit repo, changes apply immediately)

---

**Stack:** NixOS 26.05 · Hyprland · Serpantinum · Fish · Zed · Kitty
