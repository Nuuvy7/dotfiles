{ serpantinum, zen-browser, dream-journey-cursor, pkgs, ... }:

{
  imports = [
    serpantinum.homeManagerModules.default
    # Zen browser (beta) + set as default browser.
    zen-browser.homeModules.beta
  ];

  # ===== Identitas user =====
  home.username = "flos";
  home.homeDirectory = "/home/flos";
  home.stateVersion = "26.05";

  # Biar Home Manager mengurus dasar-dasarnya.
  programs.home-manager.enable = true;

  # ===== Serpantinum =====
  # HM urus: pasang paket + systemd user service (serpantinumd).
  # Konfigurasi (settings.json) dikelola manual di
  # ~/.config/serpantinum/settings.json — jangan di-set lewat settings.*
  # di sini, karena itu akan menimpa file manual lo.
  programs.serpantinum = {
    enable = true;
    systemd.enable = true;
  };

  # Paket user tambahan (sebagian tetap di systemPackages configuration.nix).
  # seclists: data-only wordlist — ditaruh di home.packages karena ada issue
  # lama di nixpkgs: seclists tidak selalu masuk closure systemPackages
  # (toplevel build bisa skip walau eval bilang ada).
  home.packages = [ pkgs.seclists ];

  # File monochrome.css (theme Zen grayscale) — ditaruh di chrome/ profil
  # biar bisa di-@import oleh userChrome.css di atas.
  # Source: github.com/antonsizikov/zen-browser-monochrome-theme (MIT)
  # Di-inline (bukan readFile path absolut) karena pure-eval nix nolak path.
  home.file.".config/zen/default/chrome/monochrome.css" = {
    text = ''
      :root {
          --zen-primary-color: #808080 !important;
      }

      @media not (prefers-color-scheme: dark) {
          :root {
              --zen-colors-primary: #D2D2D2 !important;
              --zen-colors-secondary: #D2D2D2 !important;
              --zen-colors-tertiary: #FFFFFF !important;
              --zen-colors-border: #DDDDDD !important;
          }
      }

      @media (prefers-color-scheme: dark) {
          :root {
              --zen-colors-primary: #373737 !important;
              --zen-colors-secondary: #373737 !important;
              --zen-colors-tertiary: #171717 !important;
              --zen-colors-border: #202020 !important;
          }
      }
    '';
  };

  # Dream Journey hyprcursor untuk Hyprland — Hyprland cari di
  # ~/.local/share/hyprcursors/<theme>/. Nama folder = HYPRCURSOR_THEME.
  # Di-inline dari flake input (pure-eval aman).
  xdg.dataFile."hyprcursors/pixloen-dream-journey" = {
    source = dream-journey-cursor + "/hyprcursors";
  };

  # Auto-sync TUI apps (btop/micro/nvim/kitty) ikut warna serpantinum.
  # Kalau matugen ON: mantau qs_colors.json (auto-update pas ganti wallpaper).
  # Kalau matugen OFF: mantau settings.json (ganti preset manual).
  # Dua-duanya di-trigger ke service yang sama.
  systemd.user.services.serpantinum-tui-sync = {
    Unit = {
      Description = "Sync TUI apps (btop/micro/nvim) with serpantinum theme";
      # Rate-limit longgar: wallpaper carousel bisa trigger cepat-cepat.
      # Default systemd (5x/10s) kena 'start-limit-hit'. Naikin + cooldown.
      StartLimitIntervalSec = 0;
    };
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.local/bin/serpantinum-tui-sync";
      # Cooldown biar kalau wallpaper ganti beruntun, nggak spam.
      RestartSec = "2s";
    };
  };

  systemd.user.paths.serpantinum-tui-sync = {
    Unit = {
      Description = "Watch serpantinum colors (matugen + settings) for theme changes";
    };
    Path = {
      PathChanged = [
        "%h/.local/state/serpantinum/qs_colors.json"
        "%h/.config/serpantinum/settings.json"
      ];
      Unit = "serpantinum-tui-sync.service";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # ===== Zen browser =====
  # Ganti chromium sebagai default. Preset Catppuccin Mocha (cocok tema lo)
  # + betterfox (privacy/perf). Kebaca manual lo tetap menang kalau ada.
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    profiles.default.presets.catppuccin = {
      enable = true;
      flavor = "Mocha";
      accent = "Mauve";
    };

    profiles.default.presets.betterfox.enable = true;

    # userChrome: catppuccin dulu, lalu monochrome numang (grayscale penuh,
    # support light+dark). File monochrome.css disalin ke chrome/ oleh HM.
    # (mkDefault di preset catppuccin, jadi profile-level ini yang menang.)
    profiles.default.userChrome = ''
      @import "catppuccin/userChrome.css";
      @import "monochrome.css";
    '';
  };

  # ===== Zed editor =====
  # Config dikelola manual via ~/.config/zed/settings.json (nggak di HM),
  # jadi di sini cuma mastiin paket terpasang. Autocomplete/LSP/QoL
  # diset di settings.json + keymap.json (managed manual).
  programs.zed-editor = {
    enable = true;
  };

  # ===== npm global (buat npm install -g tanpa sudo) =====
  # npm global install ke ~/.npm-global (bukan /nix read-only), dan
  # ~/.npm-global/bin di-PATH biar binary global (9router dll) bisa dipanggil.
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };
  home.sessionPath = [ "$HOME/.npm-global/bin" ];
}
