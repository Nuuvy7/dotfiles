{
  description = "NixOS 26.05 — Hyprland + Serpantinum (dotfiles templat)";

  # ===== Konfigurasi per-mesin =====
  # Ganti hostname & username di blok `let` bawah sebelum rebuild pertama kali.
  inputs = {
    # Pin ke channel 26.05.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # Serpantinum: flake-nya pin nixos-unstable sendiri di dalamnya.
    serpantinum.url = "github:ilyamiro/serpantinum";

    # Home Manager (release yang cocok untuk 26.05).
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Qylock: SDDM + Quickshell lockscreen themes.
    qylock = {
      url = "github:Darkkal44/qylock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fetch: animated 3D fetch tool.
    # Pakai overlay (bukan packages) biar ngikutin nixpkgs 26.05.
    fetch = {
      url = "github:areofyl/fetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen browser: community flake + Home Manager module.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Dream Journey cursor (XCursor + Hyprcursor) — dipindah ke repo (assets/)
    dream-journey-cursor = {
      url = "path:../assets/dream-journey-cursor";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, serpantinum, home-manager, qylock, fetch, zen-browser, dream-journey-cursor, ... }:
  let
    hostname = "windflower";
    username = "flos";
  in {
    nixosConfigurations.windflower = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit dream-journey-cursor;
        inherit hostname;
        inherit username;
      };

      modules = [
        # Pin nixpkgs sistem ke input flake kita.
        { nixpkgs.pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        }

        ./config/configuration.nix

        # Overlay: expose serpantinum + fetch sebagai pkgs.<nama>.
        { nixpkgs.overlays = [
            serpantinum.overlays.default
            fetch.overlays.default
          ];
        }

        # Module NixOS-level serpantinum (dependency sistem).
        serpantinum.nixosModules.default

        # Qylock: SDDM lockscreen theme.
        qylock.nixosModules.default
        {
          programs.qylock = {
            enable = true;
            theme = "R1999_1";
            quickshell.enable = false;
          };
        }

        # Home Manager sebagai module NixOS.
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.flos = import ./config/home.nix;
            backupFileExtension = "hm-backup";

            extraSpecialArgs = {
              serpantinum = serpantinum;
              self = self;
              zen-browser = zen-browser;
              dream-journey-cursor = dream-journey-cursor;
              pkgs = nixpkgs.legacyPackages.x86_64-linux;
              username = "flos";
            };
          };
        }
      ];
    };
  };
}
