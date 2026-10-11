#!/run/current-system/sw/bin/bash
# Dotfiles install/bootstrap — symlink repo → home + rebuild NixOS
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
DRY="${1:-}"

link() {
  local src="$REPO/$1" dest="$2"
  if [[ ! -e "$src" ]]; then echo "skip (src missing): $1"; return; fi
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "ok (already linked): $dest"; return
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    mv "$dest" "$dest.backup-dotfiles-$(date +%Y%m%d)"
    echo "backed up: $dest"
  fi
  mkdir -p "$(dirname "$dest")"
  if [[ -n "$DRY" ]]; then echo "WOULD link: $dest -> $src"; else
    ln -s "$src" "$dest"; echo "linked: $dest"
  fi
}

echo "=== app configs (home -> repo) ==="
link config/fish/config.fish          "$HOME/.config/fish/config.fish"
link config/zed/settings.json         "$HOME/.config/zed/settings.json"
link config/zed/keymap.json           "$HOME/.config/zed/keymap.json"
link config/zed/snippets/html.json    "$HOME/.config/zed/snippets/html.json"
link config/serpantinum/settings.json "$HOME/.config/serpantinum/settings.json"
link config/hypr/hyprland.conf        "$HOME/.config/hypr/hyprland.conf"
link config/kitty/kitty.conf          "$HOME/.config/kitty/kitty.conf"
link config/micro/settings.json       "$HOME/.config/micro/settings.json"
link config/btop/btop.conf            "$HOME/.config/btop/btop.conf"

echo ""
echo "=== NixOS ==="
echo "Rebuild langsung dari repo:"
echo "  cd $REPO/nixos && sudo nixos-rebuild switch --flake .#windflower"
echo ""
echo "Selesai. Kalau file baru ditambah ke repo, jalankan lagi script ini."
