# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page,
# on https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
#
# Merged 2026-10-10: config sistem lama (Arch) dari ~/deta/pindahrumah/configuration.nix
# disesuaikan untuk nixpkgs 26.05. Yang sudah ada (mount NTFS deta, nix-ld, kernel
# latest, grub OSProber, stateVersion) TIDAK ditimpa — hanya ditambah yang belum ada.

{ config, lib, pkgs, ... }:

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
  nixpkgs.config.allowUnfree = true;

  # Nix flakes + store optimise (dari config pindahrumah).
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
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
  };

  # ===== Display manager: SDDM (Wayland) =====
  # Catatan: di nixpkgs 26.05 SDDM pindah ke services.displayManager.sddm
  # (dulu services.sddm). Sistem ini sekarang jalan Hyprland langsung
  # (manual start, tanpa DM). Kalau tidak mau DM otomatis, set enable = false.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

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

  # zram (zram-generator di Arch)
  zramSwap = {
    enable = true;
    memoryPercent = 50;
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

  # ===== User =====
  users.users.flos = {
    isNormalUser = true;
    extraGroups = [
      "wheel" "networkmanager"
      "video" "audio" "input" "podman"
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

  environment.systemPackages = with pkgs; [
    # --- sudah ada di config lama (dipertahankan) ---
    vim wget vivaldi kitty fastfetch wofi git curl micro yazi starship
    gparted file fuzzel

    # --- CLI / tools baru (dari Arch) ---
    nano neovim tmux unzip
    fd fzf jq bc socat
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
    chromium obsidian zed vscodium discord
    kdePackages.dolphin nautilus
    libreoffice-still
    easyeffects
    matugen quickshell satty
    libsForQt5.qt5ct qt6Packages.qt6ct
    cava
    xdg-utils zenity
  ];

  # ===== Flatpak =====
  services.flatpak.enable = true;
  
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org
    '';
  };
  

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
