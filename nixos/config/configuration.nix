# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page,
# on https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
#
# Merged 2026-10-10: config sistem lama (Arch) dari ~/deta/pindahrumah/configuration.nix
# disesuaikan untuk nixpkgs 26.05. Yang sudah ada (mount NTFS deta, nix-ld, kernel
# latest, grub OSProber, stateVersion) TIDAK ditimpa — hanya ditambah yang belum ada.

{ config, lib, pkgs, dream-journey-cursor, ... }:

let
  # Dream Journey cursor theme (XCursor buat SDDM + apps, Hyprcursor buat Hyprland).
  # Source: file dari Downloads (Umamusume cursor pack v1.9).
  # Nama folder dikasih bersih (tanpa spasi/kurung) biar XCURSOR_THEME reliable.
  djThemeName = "pixloen-dream-journey";
  djXcursor = pkgs.runCommand "dream-journey-xcursor" { } ''
    mkdir -p $out/share/icons/${djThemeName}
    cp -r ${dream-journey-cursor}/cursors $out/share/icons/${djThemeName}/
    cp ${dream-journey-cursor}/index.theme $out/share/icons/${djThemeName}/
    # Fix nama di index.theme biar cocok sama folder.
    sed -i "s|^Name=.*|Name=${djThemeName}|" $out/share/icons/${djThemeName}/index.theme
  '';
  djHyprcursor = pkgs.runCommand "dream-journey-hyprcursor" { } ''
    mkdir -p $out/share/hyprcursors
    cp ${dream-journey-cursor}/hyprcursors/*.hlc $out/share/hyprcursors/
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the grub EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    timeout = 30; # detik sebelum opsi atas dipilih otomatis
  };

  # NTFS mount untuk SSD deta (shared, NTFS) — sudah ada, dipertahankan.
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/home/flos/deta" = {
    device = "/dev/disk/by-uuid/B12887EDA87FC161";
    fsType = "ntfs";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "dmask=022"
      "fmask=133"
      "nofail"
      "x-systemd.device-timeout=5s"
    ];
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Catatan: nixpkgs.config.allowUnfree (Steam) dipindah ke flake.nix,
  # karena flake-based config tidak boleh meng-set nixpkgs.config di sini.

  # Nix flakes + store optimise (dari config pindahrumah).
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Nix GC otomatis: mingguan, buang store path nggak kepake +
  # generasi >7 hari. NixOS default nggak auto-GC; dry-run nix-collect-garbage
  # udah kelihatan ~1138 path bisa dibuang, jadi lama-lama numpuk kalau
  # nggak dikasih timer.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # ===== Networking =====
  networking.hostName = "windflower"; # hostname dari config pindahrumah
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # ===== Time & locale =====
  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "id_ID.UTF-8";
    LC_IDENTIFICATION = "id_ID.UTF-8";
    LC_MEASUREMENT = "id_ID.UTF-8";
    LC_MONETARY = "id_ID.UTF-8";
    LC_NAME = "id_ID.UTF-8";
    LC_NUMERIC = "id_ID.UTF-8";
    LC_PAPER = "id_ID.UTF-8";
    LC_TELEPHONE = "id_ID.UTF-8";
    LC_TIME = "id_ID.UTF-8";
  };
  console.keyMap = "us";

  # ===== Desktop: Hyprland (dengan UWSM + portal Wayland) =====
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = [ "hyprland" "gtk" ];
    xdgOpenUsePortal = true;
  };

  # ===== Dark mode system-wide =====
  # GTK2/3/4 & Qt5/6 auto-dark. Aplikasi ikut preferensi sistem
  # tanpa set manual. Kalau app bandel, tinggal restart app-nya.
  environment.variables = {
    GTK_THEME = "Adwaita:dark";
    # Dream Journey cursor (system-level, biar SDDM + semua app baca).
    XCURSOR_THEME = "pixloen-dream-journey";
    XCURSOR_SIZE = "24";
    # Hyprland pakai hyprcursor (.hlc).
    HYPRCURSOR_THEME = "pixloen-dream-journey";
    HYPRCURSOR_SIZE = "24";
  };
  qt = {
    enable = true;
    # Qt ikut tema GTK (baca dark dari GTK_THEME=Adwaita:dark).
    # Catatan: nixpkgs 26.05 cuma terima "gtk2" (bukan "gtk").
    platformTheme = "gtk2";
  };

  # ===== Display manager: SDDM (Wayland) =====
  # Catatan: di nixpkgs 26.05 SDDM pindah ke services.displayManager.sddm
  # (dulu services.sddm). Sistem ini sekarang jalan Hyprland langsung
  # (manual start, tanpa DM). Kalau tidak mau DM otomatis, set enable = false.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    # NOTE: compositorCommand weston --shell=fullscreen dicoba tapi bikin
    # blackscreen sama greeter qylock — di-revert ke default (weston kiosk).
    # Cursor invisible di SDDM masih open issue (kiosk shell nggak expose pointer).
  };

  # ===== SDDM cursor fix =====
  # NOTE: percobaan fix cursor invisible di SDDM:
  # - Tema cursor Dream Journey (XCursor) udah kepasang di /share/icons ✓
  # - XCURSOR_THEME udah ke-set di service display-manager (biar SDDM baca) ✓
  # - Tapi weston --shell=kiosk (compositor default SDDM) NYEMBUNYIIN pointer,
  #   jadi cursor tetap nggak muncul. Ini karakteristik kiosk shell, bukan tema.
  # - Percobaan ganti ke --shell=fullscreen → blackscreen (greeter qylock
  #   nggak kompatibel). Di-revert.
  # - Opsi lain yang belum dicoba: compositor lain (cage/drm), atau terima
  #   SDDM nggak ada cursor (desktop udah ada Dream Journey).
  systemd.services.display-manager.serviceConfig = {
    Environment = [
      "XCURSOR_THEME=pixloen-dream-journey"
      "XCURSOR_SIZE=24"
      "XCURSOR_PATH=/run/current-system/sw/share/icons"
    ];
  };

  # ===== Notifikasi: dunst =====
  # Notification daemon (Wayland-native). Tanpa ini, notify-send -A (yang
  # dipakai serpantinum screenshot buat action button) HANG karena nggak ada
  # daemon yang handle → screenshot command nggak kelar-kelar.
  services.dunst = {
    enable = true;
    enableWayland = true;  # Wayland-native notification daemon buat Hyprland
  };
  # dunstrc di-set via environment.etc (NixOS sistem level, bukan HM xdg).
  environment.etc."dunst/dunstrc".text = ''
    [global]
    monitor = 0
    follow = mouse
    width = 320
    height = (0, 300)
    origin = top-right
    offset = (20, 20)
    scale = 0
    notification_limit = 5
    progress_bar = true
    progress_bar_height = 10
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 300
    progress_bar_corner_radius = 10
    icon_corner_radius = 10
    indicate_hidden = yes
    transparency = 10
    separator_height = 2
    padding = 12
    horizontal_padding = 12
    text_icon_padding = 12
    frame_width = 2
    frame_color = "#1a1a1a"
    gap_size = 0
    separator_color = frame
    sort = yes
    idle_threshold = 120
    line_height = 0
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes
    sticky_history = yes
    history_length = 20
    always_run_script = true
    corner_radius = 10
    mouse_left_click = close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all

    [urgency_low]
    background = "#1a1a1a"
    foreground = "#ffffff"
    frame_color = "#2a2a2a"
    timeout = 5

    [urgency_normal]
    background = "#1a1a1a"
    foreground = "#ffffff"
    frame_color = "#2a2a2a"
    timeout = 8

    [urgency_critical]
    background = "#1a1a1a"
    foreground = "#ffb4ab"
    frame_color = "#ffb4ab"
    timeout = 0
  '';

  # ===== Audio (pipewire penuh, dari Arch) =====
  # support32Bit: Steam (programs.steam) butuh true untuk ALSA 32-bit,
  # jadi pakai mkForce true supaya tidak konflik dengan defaults.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = lib.mkForce true;
    pulse.enable = true;
    jack.enable = true;
  };
  security.rtkit.enable = true;

  # ===== Bluetooth =====
  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # ===== Power / laptop =====
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.dbus.enable = true;
  services.thermald.enable = true;

  # ===== Printing: dimatikan (tidak ada printer di sistem lama) =====
  services.printing.enable = false;

  # ===== Time sync =====
  services.timesyncd.enable = true;

  # ===== Flatpak (Flathub) =====
  services.flatpak.enable = true;

  security.polkit.enable = true;

  # ===== Hardware khas laptop (Intel Alder Lake, i5-1235U) =====
  # intel-media-driver + intel-vaapi-driver sudah ada; vaapiIntel & vulkan-intel
  # sudah dihapus dari nixpkgs 26.05 — fungsinya masuk hardware.graphics dibawah.
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva
      mesa
      vulkan-loader
      vulkan-tools
    ];
  };
  hardware.cpu.intel.updateMicrocode = true;

  # ===== Performance preset =====
  # CPU: performance via power-profiles-daemon (cpufreq.service doang nggak cukup —
  # PPD start lebih akhir dan override governor balik ke powersave).
  systemd.services.power-profile-performance = {
    description = "Force power profile: performance on boot";
    after = [ "power-profiles-daemon.service" ];
    wants = [ "power-profiles-daemon.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance";
      RemainAfterExit = true;
    };
  };

  # Kernel params: disable Spectre/Meltdown mitigations (+5-10% performa)
  # NOTE: mitigations=off = buka resiko side-channel attack. Personal laptop,
  # nggak ada multi-user → risk acceptable. Hapus baris ini kalau mau security balik.
  boot.kernelParams = [ "mitigations=off" "nowatchdog" ];

  # Sysctl tuning: RAM-first (swappiness rendah karena zram bukan primary),
  # cache dipertahankan lebih lama, dirty pages flush lebih cepat (responsif I/O).
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  # zram (zram-generator di Arch) — target ~8G via percent RAM.
  # Pakai memoryPercent (empirinya stabil); memoryMax di module punya
  # konversi unit yang bikin zram-size conf nggak kebaca bener.
  zramSwap = {
    enable = true;
    memoryPercent = 107;  # 107% × 7.5G RAM ≈ 8G (zram compressed, > RAM normal)
  };

  # ===== Fonts =====
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji # nama baru: noto-fonts-emoji dihapus
    nerd-fonts.jetbrains-mono
    inter
  ];

  # ===== Steam / gaming =====
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  hardware.steam-hardware.enable = true;
  programs.gamescope.enable = true;

  # ===== Podman (dockerCompat) =====
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # ===== Database (kelas DB) =====
  # MySQL 8.4 server + client, PostgreSQL 17 server + client, DBeaver GUI.
  # Semua service auto-start pas boot; data disimpan di /var/lib/{mysql,postgresql}.
  services.mysql = {
    enable = true;
    package = pkgs.mysql84;
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
  };

  # ===== Web stack buat belajar DB (pengganti XAMPP) =====
  # Apache + PHP 8.3 (dengan mysqli/pdo_mysql/pdo_pgsql) + Adminer
  # (pengganti phpMyAdmin — dihapus dari nixpkgs 26.05).
  # phpMyAdmin akses: http://localhost:8080 (setelah rebuild).
  services.httpd = {
    enable = true;
    adminAddr = "flos@localhost";
    extraModules = [ "proxy_fcgi" ];
    virtualHosts."db.belajar.local" = {
      documentRoot = "/var/www";
      extraConfig = ''
        <Directory "/var/www">
          Options FollowSymLinks Indexes
          AllowOverride None
          Require all granted
          DirectoryIndex adminer.php
          <FilesMatch \.php$>
            SetHandler "proxy:unix:/run/phpfpm/db.sock|fcgi://localhost/"
          </FilesMatch>
        </Directory>
      '';
    };
  };

  services.phpfpm = {
    phpPackage = pkgs.php83.buildEnv {
      extensions = { all, ... }: with all; [
        mysqli
        pdo_mysql
        pdo_pgsql
        pdo_sqlite
      ];
    };
    pools.db = {
      user = "flos";
      group = "users";
      settings = {
        "listen.owner" = "flos";
        "listen.group" = "wwwrun";
        "listen.mode" = "0660";
        "pm" = "dynamic";
        "pm.max_children" = 5;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
      };
    };
  };

  # ===== User =====
  users.users.flos = {
    isNormalUser = true;
    extraGroups = [
      "wheel" "networkmanager"
      "video" "audio" "input" "podman"
      "mysql" "postgres"
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  # nix-ld: jalankan binary non-NixOS (sudah ada, dipertahankan).
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    curl
  ];

  # ===== Serpantinum: shell Wayland (Quickshell) untuk Hyprland =====
  # NixOS module mengurus dependency sistem (networkmanager, bluetooth,
  # pipewire, rtkit, power-profiles, font nerd). Konfigurasi user +
  # layanan systemd --user dikelola lewat Home Manager (home.nix).
  programs.serpantinum.enable = true;

  environment.systemPackages = with pkgs; [
    # --- sudah ada di config lama (dipertahankan) ---
    # vivaldi dihapus (user nggak cocok).
    vim wget kitty fastfetch wofi git curl micro yazi starship
    gparted file fuzzel

    # --- CLI / tools baru (dari Arch) ---
    nano neovim tmux unzip
    fd fzf jq bc socat
    himalaya                     # email CLI — cron cek-tugas-classroom (backup config: ~/.config/himalaya/config.toml)
    btop htop
    hyfetch                       # neofetch sudah dihapus upstream, hyfetch penggantinya
    p7zip
    acpi smartmontools efibootmgr
    wl-clipboard grim slurp wf-recorder dunst
    brightnessctl pamixer pavucontrol playerctl libnotify
    cliphist wmctrl w3m zbar figlet cmatrix
    inotify-tools iw wpa_supplicant
    dnsmasq                       # ufw tidak ada di nixpkgs; firewall pakai networking.firewall
    python312Packages.pip python312Packages.pipx
    flatpak podman-compose

    # --- Desktop / GUI baru (dari Arch) ---
    # chromium & vivaldi dihapus — Zen browser jadi default (via Home Manager).
    obsidian zed discord
    kdePackages.dolphin nautilus
    libreoffice-still
    easyeffects
    matugen quickshell satty
    libsForQt5.qt5ct qt6Packages.qt6ct
    # Dark mode theming: GTK (adw-gtk3) + Qt6 (adwaita-qt6).
    adw-gtk3 adwaita-qt6
    cava
    xdg-utils zenity
    xdg-user-dirs   # xdg-user-dir: dipakai serpantinum buat resolusi folder Pictures (launcher/wallpaper)
    pulseaudio      # pactl (client) — serpantinum screenshot butuh ini (mute/unmute shutter sound). Pipewire yang handle audio, pactl cuma client.
    areofyl-fetch  # animated 3D fetch tool (overlay dari flake fetch)
    nodejs         # node + npm sistem-wide (buat npm install -g 9router dll)
    djXcursor      # Dream Journey XCursor theme (SDDM + apps)
    djHyprcursor   # Dream Journey Hyprcursor (.hlc untuk Hyprland)

    # --- Database GUI (kelas DB) ---
    dbeaver-bin    # GUI universal: MySQL + PostgreSQL + SQLite (paling enak buat belajar)

    # --- Cyber / CTF (kelas 11 — niat serius) ---
    burpsuite      # web proxy (unfree, allowUnfree sudah on di flake)
    binwalk        # firmware/embedded forensics
    nmap ffuf sqlmap gobuster
    hashcat john   # password cracking
    wireshark
    ghidra         # reverse engineering — ~2GB, hapus kalau berat
  ];

  # ===== AUR alternatif (catatan, tidak dieksekusi) =====
  # Paket AUR yang tidak ada di nixpkgs → distrobox Arch container:
  #   distrobox-create -n arch -i archlinux:latest  → paru + AUR asli
  #   (antigravity-cli, antigravity-ide, vita3k-bin, xampp, dll)
  # Waydroid → flatpak/distrobox (modul nixpkgs belum full support).

  # This value defines the first version of NixOS you have installed on this
  # particular machine, and is used to maintain compatibility with application
  # data (e.g. databases) created on older NixOS versions.
  system.stateVersion = "26.05"; # Did you read the comment?

}
