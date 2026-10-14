# dotfiles — NixOS Template

Template dotfiles NixOS 26.05 + Hyprland + Serpantinum. Flake-based, reproducible, siap buat mesin baru.

## 📦 Isi

```
nixos/
├── flake.nix                    # Flake: inputs (nixpkgs, home-manager, serpantinum, qylock, fetch, zen)
├── flake.lock
└── config/
    ├── configuration.nix        # System config (packages, services, Hyprland, DB, CTF tools)
    ├── hardware-configuration.nix # GENERATE SENDIRI — jangan commit
    └── home.nix                 # Home Manager (serpantinum, zen, zed, npm)

config/
├── fish/config.fish             # Shell config
├── zed/                         # Editor settings
├── serpantinum/settings.json    # Wayland shell
├── hypr/hyprland.conf           # WM
├── kitty/kitty.conf             # Terminal
├── micro/settings.json          # Text editor
└── btop/btop.conf               # System monitor

install.sh                       # Symlink config apps ke ~/.config/
```

## 🚀 Setup Mesin Baru

### Prasyarat
- NixOS live ISO udah boot
- Internet aktif
- Git terinstall (`nix-shell -p git`)

### 1. Clone repo
```bash
git clone https://github.com/Nuuvy7/dotfiles ~/dotfiles
cd ~/dotfiles
```

### 2. Generate hardware-config
```bash
# Cek disk kamu dulu
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT

# Generate (JANGAN pakai yang di repo — itu UUID disk flos)
sudo nixos-generate-config --show-hardware-config > nixos/config/hardware-configuration.nix
```

### 3. Set hostname + username
Edit `nixos/flake.nix` specialArgs:
```nix
specialArgs = {
  hostname = "nama-mesin-kamu";   # misal "laptop-budi"
  username = "user-kamu";         # misal "budi"
};
```

Atau pakai env var saat rebuild (nggak usah edit flake):
```bash
NIXOS_HOSTNAME=nama-mesin-kamu NIXOS_USERNAME=user-kamu \
  sudo -E nixos-rebuild switch --flake .#windflower
```

### 4. Hapus mount SSD deta (kalau bukan punya flos)
Edit `nixos/config/configuration.nix`, hapus blok:
```nix
fileSystems."/home/${username}/deta" = { ... };
```

### 5. Symlink app configs
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

## 🔧 Daily Workflow

**Edit config** (selalu di `~/dotfiles`):
```bash
cd ~/dotfiles
# Edit nixos/config/home.nix atau config/zed/settings.json
git add -A && git commit -m "feat: tambah package X"
git push
```

**Rebuild:**
```bash
cd ~/dotfiles/nixos
sudo nixos-rebuild switch --flake .#windflower
```

**Update inputs:**
```bash
cd ~/dotfiles/nixos
nix flake update
sudo nixos-rebuild switch --flake .#windflower
```

## ⚙️ Yang Bisa Dikustomisasi

| Apa | Di mana | Cara |
|---|---|---|
| Hostname | `flake.nix` specialArgs | Edit atau env var `NIXOS_HOSTNAME` |
| Username | `flake.nix` specialArgs | Edit atau env var `NIXOS_USERNAME` |
| Packages | `config/configuration.nix` systemPackages | Edit langsung |
| Home packages | `config/home.nix` home.packages | Edit langsung |
| App configs (zed, hypr, dll) | `config/` | Edit langsung, symlink otomatis |
| Mount SSD deta | `config/configuration.nix` fileSystems | Hapus kalau nggak punya SSD itu |

## 📝 Catatan Penting

- **hardware-configuration.nix JANGAN di-commit** — generate sendiri tiap mesin (UUID beda-beda)
- **Secret files** (`.env`, `auth.json`, `*credentials*`) gitignored — setup manual per mesin
- **First rebuild** ~15 menit (download + compile semua packages)
- **App configs di `~/dotfiles/config/` di-symlink ke `~/.config/`** — edit di repo, langsung berlaku
- **`../../../etc/nixos/` dan `~/.config/` itu GENERATED** — jangan edit langsung, edit di `~/dotfiles` lalu rebuild
