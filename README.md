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
├── fish/config.fish           # Shell (PATH fix untuk 9router)
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

- **Serpantinum 2.2.6** — bar, quickshell modules, matugen color sync
- **9router** + **hermes-gateway** — systemd auto-start/restart, Discord 4-bot multiplexed
- **Zen Browser** — default browser, monochrome theme
- **Zed Editor** — 60+ HTML snippets, auto-completion
- **Dream Journey Cursor** — XCursor + Hyprcursor
- **TUI sync** — btop, micro, nvim, kitty, hermes skin follow serpantinum colors

## 📝 Notes

- `hardware-configuration.nix` di-gitignore (per-machine)
- Secret files (`.env`, `auth.json`, `*credentials*`) di-gitignore — setup manual per mesin
- Rebuild pertama: ~15 menit (download + compile)
- Theme taman Windflower: lifecycle notif gateway pakai 🌸🌙 konsisten

---

**Host:** windflower (NixOS 26.05)  
**User:** flos  
**WM:** Hyprland + Serpantinum  
**Shell:** Fish  
**Editor:** Zed, Micro
