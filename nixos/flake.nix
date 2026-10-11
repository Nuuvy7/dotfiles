{
  description = "Windflower — NixOS 26.05 (flos)";

  inputs = {
    # Pin ke channel 26.05 yang sama dengan sistem lo.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # Serpantinum: flake-nya pin nixos-unstable sendiri di dalamnya.
    serpantinum.url = "github:ilyamiro/serpantinum";

    # Home Manager (release yang cocok untuk 26.05).
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Qylock: SDDM + Quickshell lockscreen themes (dari clone lokal).
    # nixpkgs-nya di-follow ke 26.05 lo biar nggak narik unstable besar.
    qylock = {
      url = "path:/home/flos/Projects/clone/qylock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fetch: animated 3D fetch tool (dari clone lokal).
    # Pakai overlay (bukan packages) biar ngikutin nixpkgs 26.05 lo,
    # bukan unstable yang di-pin flake fetch-nya sendiri.
    fetch = {
      url = "path:/home/flos/Projects/clone/fetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen browser: community flake (dari clone lokal) + Home Manager module.
    # Zen nggak ada di nixpkgs 26.05, jadi pakai flake ini.
    zen-browser = {
      url = "path:/home/flos/Projects/clone/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Dream Journey cursor (XCursor + Hyprcursor) — file dari Downloads.
    dream-journey-cursor = {
      url = "path:/home/flos/Projects/clone/dream-journey-cursor";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, serpantinum, home-manager, qylock, fetch, zen-browser, dream-journey-cursor, ... }: {
    nixosConfigurations.windflower = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # Kirim cursor source ke configuration.nix buat dibikin derivasi.
      specialArgs = { inherit dream-journey-cursor; };

      modules = [
        # Pin nixpkgs sistem ke input flake kita.
        # allowUnfree=true (Steam) dipindah ke sini karena flake-based
        # config tidak boleh meng-set nixpkgs.config di configuration.nix.
        { nixpkgs.pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        }

        ./config/configuration.nix

        # Overlay: expose serpantinum + fetch sebagai pkgs.<nama>.
        # Dipakai oleh configuration.nix (systemPackages) kalau perlu.
        { nixpkgs.overlays = [
            serpantinum.overlays.default
            fetch.overlays.default
          ];
        }

        # Module NixOS-level serpantinum (dependency sistem).
        serpantinum.nixosModules.default

        # Qylock: SDDM lockscreen theme (Reverse:1999).
        # Hanya SDDM — quickshell dimatikan karena repo punya dangling
        # symlink QtGraphicalEffects yang nix sandbox nolak (bukan bagian SDDM).
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

            # Home Manager module serpantinum butuh argumen `self` = flake
            # serpantinum (untuk self.packages.<system>.default).
            extraSpecialArgs = {
              serpantinum = serpantinum;
              self = self;
              zen-browser = zen-browser;
              dream-journey-cursor = dream-journey-cursor;
              pkgs = nixpkgs.legacyPackages.x86_64-linux;
            };
          };
        }
      ];
    };
  };
}
