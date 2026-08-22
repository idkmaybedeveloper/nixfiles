{
  description = "Lain nixfiles monorepo :3";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://cache.wejust.rest/labs"
      "http://shit.cuddles.rs/nixos" # TODO: move to https when fixed
      #"https://nix-community.cachix.org" OHNO timeout
      "http://shit.cuddles.rs/mac" # mac cache from my macboob (m68k)
    ];
    extra-trusted-public-keys = [
      "labs:1+w3w/rjRYzPhQals2BIspD0DZSyNmCP+dD76gGQPGU="
      "shit.cuddles.rs:HQ4GqwV3aPbneoDdl4diqMcRjmusLqtQkETdebH62sk="
      #"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "mac.air-m3:nb7c5XDpotsC9UgU/g4r1zBDc85KK0bGNDfR7zCSDmQ="
    ];
  };

  inputs = {
    # NOTE: per-host nixpkgs, my favourite nixpkgs versions zoo
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # macmini, x230 (eva01)
    nixpkgs-2605.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin"; # darwin (m68k)
    nixpkgs-2511.url = "github:NixOS/nixpkgs/nixos-25.11"; # nixvm, playground1, playground2, puppy
    nixpkgs-2411.url = "github:NixOS/nixpkgs/nixos-24.11"; # nixvm (macvm)
    nixpkgs-2405.url = "github:NixOS/nixpkgs/nixos-24.05"; # nix-on-droid

    # home-manager
    home-manager-2605 = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # declarative plasma config (alphys)
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # nix-darwin
    darwin-2605 = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
    darwin-2511 = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-2511";
    };

    # shared
    attic.url = "github:zhaofengli/attic";
    # network/infra diagrams generated from the nixos configs themselves
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware"; # alphys (surface laptop 3)
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # remote installer (puppy), pinned so every box gets the same one
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };
    # helium browser for linux (alphys). the other `helium` input is the mac build
    helium-linux = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # darwin (m68k)
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-php = {
      url = "github:shivammathur/homebrew-php";
      flake = false;
    };
    homebrew-microsoft = {
      url = "github:microsoft/homebrew-git";
      flake = false;
    };
    homebrew-blacktop = {
      url = "github:blacktop/homebrew-tap";
      flake = false;
    };
    homebrew-fuse-t = {
      url = "github:macos-fuse-t/homebrew-cask";
      flake = false;
    };
    homebrew-lain = {
      url = "git+https://code.wejust.rest/lain/homebrew-tap";
      flake = false;
    };
    homebrew-FelixKratz = {
      url = "git+https://github.com/FelixKratz/homebrew-formulae";
      flake = false;
    };
    homebrew-sikarugir = {
      url = "github:Sikarugir-App/homebrew-sikarugir";
      flake = false;
    };
    homebrew-wine = {
      url = "github:gcenx/homebrew-wine";
      flake = false;
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    helium.url = "git+https://code.wejust.rest/lain/helium-mac.git";
    nixcursor = {
      url = "git+https://code.cuddles.rs/lain/nixcursor";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };

    # macmini
    mailserver = {
      url = "git+https://code.wejust.rest/mirror/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #borrowd.url = "git+https://nx.cuddles.rs/lain/borrowd"; # TODO: public release?

    # playgrounds
    cursed-ping.url = "git+https://git.fuckyougoogle.xyz/lain/cursed-ping";
    tangled.url = "git+https://code.cuddles.rs/tangled/core"; # keep in sync with https://tangled.org/tangled.org/core
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-2511";
    };

    # nix-on-droid
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-2405";
    };

    vivienne = {
      url = "git+https://code.cuddles.rs/lain/Vivienne";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };

    late-sh = {
      url = "github:mpiorowski/late-sh";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-2605,
      nixpkgs-2511,
      nixpkgs-2411,
      nixpkgs-2405,
      home-manager,
      home-manager-2605,
      plasma-manager,
      darwin-2605,
      darwin-2511,
      attic,
      nix-topology,
      nixos-hardware,
      disko,
      nixos-anywhere,
      helium-linux,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      homebrew-php,
      homebrew-microsoft,
      homebrew-blacktop,
      homebrew-fuse-t,
      homebrew-lain,
      homebrew-FelixKratz,
      homebrew-sikarugir,
      homebrew-wine,
      nixvim,
      nix-vscode-extensions,
      helium,
      nixcursor,
      mailserver,
      #borrowd,
      cursed-ping,
      tangled,
      nix-minecraft,
      sops-nix,
      nix-on-droid,
      vivienne,
      late-sh,
      ...
    }@inputs:
    let
      darwinSystem = "aarch64-darwin";
      darwinPkgs = nixpkgs-2605.legacyPackages.${darwinSystem};

      specialArgsCommon = {
        inherit inputs;
        outputs = self;
        abs = path: ./. + ("/" + path);
        partials = import ./lib/partials;
      };

      # NOTE: each host pins its own nixpkgs (the zoo above), so the helpers take
      # the desired nixpkgs/darwin input explicitly instead of capturing one
      # NOTE: when a host gets its pkgs from here, nixpkgs.config in its modules
      # is rejected by the assertion in nixos/modules/misc/nixpkgs.nix, so the
      # per-host config bits have to be threaded in as the third argument
      mkPkgs =
        nixpkgs: system: config:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = false;
          }
          // config;
        };

      mkNixosSystem =
        {
          nixpkgs,
          system ? "x86_64-linux",
          pkgs ? null,
          modules ? [ ],
          specialArgs ? { },
        }:
        nixpkgs.lib.nixosSystem (
          {
            inherit system;
            modules = [ ./hosts/nixos-common.nix ] ++ modules;
            specialArgs = specialArgsCommon // specialArgs;
          }
          // nixpkgs.lib.optionalAttrs (pkgs != null) { inherit pkgs; }
        );

      # nix-topology renders on whatever host we happen to be sitting at, so the
      # package set for it is separate from the per-host zoo above
      mkTopology =
        system:
        import nix-topology {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = false;
            overlays = [ nix-topology.overlays.default ];
          };
          modules = [
            ./topology.nix
            { nixosConfigurations = self.nixosConfigurations; }
          ];
        };

      mkDarwinSystem =
        {
          darwin,
          system,
          modules ? [ ],
          specialArgs ? { },
        }:
        darwin.lib.darwinSystem {
          inherit system modules;
          specialArgs = specialArgsCommon // specialArgs;
        };
    in
    {
      formatter.${darwinSystem} = darwinPkgs.nixfmt-tree;

      # nix build .#topology.aarch64-darwin.config.output
      topology = {
        aarch64-darwin = mkTopology "aarch64-darwin";
        x86_64-linux = mkTopology "x86_64-linux";
      };

      # nix run .#nixos-anywhere -- --flake .#puppy root@puppyip
      apps.${darwinSystem}.nixos-anywhere = {
        type = "app";
        program = "${nixos-anywhere.packages.${darwinSystem}.default}/bin/nixos-anywhere";
      };

      darwinConfigurations = {
        # m68k (macOS)
        m68k = mkDarwinSystem {
          darwin = darwin-2605;
          system = "aarch64-darwin";

          specialArgs = {
            inherit
              nix-homebrew
              homebrew-core
              homebrew-cask
              homebrew-php
              homebrew-microsoft
              homebrew-blacktop
              homebrew-fuse-t
              homebrew-lain
              homebrew-FelixKratz
              homebrew-sikarugir
              homebrew-wine
              ;
          };

          modules = [
            ./hosts/darwin/darwin-configuration.nix
            vivienne.darwinModules.default
            nixcursor.darwinModules.default
            sops-nix.darwinModules.sops

            home-manager-2605.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.lain =
                { config, pkgs, ... }:
                {
                  imports = [
                    ./hosts/darwin/home.nix
                    nixvim.homeModules.nixvim
                  ];
                  _module.args.attic = attic;
                  _module.args.vscode-extensions = nix-vscode-extensions.extensions.${darwinSystem};
                };
            }
            {
              nixpkgs.overlays = [
                late-sh.overlays.default
                helium.overlays.default
                (import ./lib/fuckyoudotnet.nix)
                (final: prev: {
                  python3Packages = prev.python3Packages.overrideScope (
                    pyFinal: pyPrev: {
                      click_8_1 = pyPrev.click.overridePythonAttrs (oldAttrs: {
                        version = "8.1.8";
                        src = pyPrev.fetchPypi {
                          pname = "click";
                          version = "8.1.8";
                          hash = "sha256-7VPJ2JkNg8Kifermjk7jN0c/YzDAQKMdQiXJV00WCWo=";
                        };
                        patches = [ ];
                        doCheck = false;
                      });
                      trezor = pyPrev.trezor.overridePythonAttrs (oldAttrs: {
                        propagatedBuildInputs =
                          final.lib.lists.filter (dep: (dep.pname or "") != "click" && dep != pyPrev.click) (
                            oldAttrs.propagatedBuildInputs or [ ]
                          )
                          ++ [ pyFinal.click_8_1 ];
                      });
                    }
                  );
                })
              ];
            }
          ];
        };

        # macvm (nixvm)
        macvm = mkDarwinSystem {
          darwin = darwin-2511;
          system = "x86_64-darwin";
          specialArgs = {
            pkgs-2411 = import nixpkgs-2411 {
              system = "x86_64-darwin";
              config.allowUnfree = false;
            };
          };
          modules = [
            {
              networking.localHostName = "macvm";
              networking.computerName = "macvm";
              system.stateVersion = 5;
            }
            ./hosts/nixvm/macs
          ];
        };
      };

      nixosConfigurations = {
        # macmini
        macmini = mkNixosSystem {
          nixpkgs = nixpkgs;
          pkgs = mkPkgs nixpkgs "x86_64-linux" { };
          #specialArgs = { inherit borrowd; };
          modules = [
            ./hosts/macmini/configuration.nix
            mailserver.nixosModules.mailserver
          ];
        };

        # nixvm
        nixvm = mkNixosSystem {
          nixpkgs = nixpkgs-2511;
          # angie is flagged insecure in nixpkgs: not a CVE, just "insufficiently
          # maintained". we still serve http with it
          pkgs = mkPkgs nixpkgs-2511 "x86_64-linux" {
            permittedInsecurePackages = [ "angie-1.12.1" ];
          };
          specialArgs = { inherit attic; };
          modules = [
            ./hosts/nixvm/configuration.nix
          ];
        };

        # playground1
        playground1 = mkNixosSystem {
          nixpkgs = nixpkgs-2511;
          pkgs = mkPkgs nixpkgs-2511 "x86_64-linux" { };
          specialArgs = { inherit cursed-ping attic; };
          modules = [
            ./hosts/playground1/configuration.nix
            tangled.nixosModules.knot
          ];
        };

        # playground2
        playground2 = mkNixosSystem {
          nixpkgs = nixpkgs-2511;
          specialArgs = { inherit cursed-ping nix-minecraft; };
          modules = [
            ./hosts/playground2/configuration.nix
            sops-nix.nixosModules.sops
            tangled.nixosModules.knot
          ];
        };

        puppy = mkNixosSystem {
          nixpkgs = nixpkgs-2511;
          modules = [
            ./hosts/puppy/configuration.nix
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
          ];
        };

        # eva01 (x230)
        eva01 = mkNixosSystem {
          nixpkgs = nixpkgs;
          modules = [
            ./hosts/x230/configuration.nix
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.lain = import ./hosts/x230/home.nix;
            }
          ];
        };

        # alphys (surface laptop 3)
        alphys = mkNixosSystem {
          nixpkgs = nixpkgs;
          modules = [
            ./hosts/alphys/configuration.nix
            nixos-hardware.nixosModules.microsoft-surface-common
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # plasma likes to write into files home-manager also owns
              home-manager.backupFileExtension = "backup";
              home-manager.users.lain =
                { config, pkgs, ... }:
                {
                  imports = [
                    plasma-manager.homeModules.plasma-manager
                    ./hosts/alphys/home.nix
                  ];
                  _module.args.vscode-extensions = nix-vscode-extensions.extensions.x86_64-linux;
                };
            }
          ];
        };
      };

      # nix-on-droid
      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs-2405 { system = "aarch64-linux"; };
        modules = [ ./hosts/nix-on-droid/nix-on-droid.nix ];
      };

      hydraJobs = {
        # TODO: reselfhost hydra
        playground1.x86_64-linux = self.nixosConfigurations.playground1.config.system.build.toplevel;
        playground2.x86_64-linux = self.nixosConfigurations.playground2.config.system.build.toplevel;
      };
    };
}
