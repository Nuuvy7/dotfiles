# dotfiles — NixOS + Hyprland + Serpantinum

Konfigurasi lengkap mesin `windflower` (NixOS 26.05) — declarative system + app configs.

## 📦 Isi

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
├── zed/                       # Editor (60+ HTML snippets)
├── serpantinum/settings.json  # Wayland shell (bar modules, wallpaper)
├── hypr/hyprland.conf         # WM
├── kitty/kitty.conf           # Terminal
├── micro/settings.json        # Text editor
└── btop/btop.conf             # System monitor
```

## 🚀 Bootstrap mesin baru

```bash
# 1. Clone repo
git clone https://github.com/nuuvy7/dotfiles ~/dotfiles
cd ~/dotfiles

# 2. Link app configs ke home
chmod +x install.sh
./install.sh

# 3. Rebuild NixOS dari repo
cd nixos
sudo nixos-rebuild switch --flake .#windflower

# 4. Reboot
sudo reboot
```

## 🔧 Workflow sehari-hari

**Edit config:**
```bash
cd ~/dotfiles
# edit nixos/config/home.nix atau app config lain
git add -A && git commit -m "feat: tambah package X"
git push
```

**Rebuild system:**
```bash
cd ~/dotfiles/nixos
sudo nixos-rebuild switch --flake .#windflower
```

**Update inputs (nixpkgs, home-manager, dll):**
```bash
cd ~/dotfiles/nixos
nix flake update
sudo nixos-rebuild switch --flake .#windflower
```

## ⚙️ Highlight

- **Serpantinum 2.2.6** — Wayland shell/bar (auto-install via flake), quickshell modules, matugen color sync
- **Zen Browser** — default browser, monochrome theme
- **Zed Editor** — 60+ HTML snippets, auto-completion
- **Dream Journey Cursor** — XCursor + Hyprcursor (auto-install via flake)
- **TUI sync** — btop, micro, nvim, kitty follow serpantinum colors
- **Qylock** — lockscreen theme available di flake (belum enabled, manual opt-in)

## 📝 Notes

- `hardware-configuration.nix` **di-track** (per-machine tapi perlu buat bootstrap; edit manual kalau ganti hardware)
- Secret files (`.env`, `auth.json`, `*credentials*`, `*.token`) di-gitignore — setup manual per mesin
- Rebuild pertama: ~15 menit (download + compile)

---

**Host:** windflower (NixOS 26.05)  
**User:** flos  
**WM:** Hyprland + Serpantinum  
**Shell:** Fish  
**Editor:** Zed, Micro
