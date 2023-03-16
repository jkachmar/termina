inputs @ {
  # Nix package sets.
  macosPkgs,
  nixosPkgs,
  unstable,
  # 3rd-party utilities.
  darwin,
  flake-utils,
  macosHome,
  nixosHome,
  ...
}: rec {
  # system = string
  # systems :: [system]
  systems = with flake-utils.lib.system; [
    aarch64-darwin
    x86_64-darwin
    x86_64-linux
  ];

  # eachSystem :: [system] -> (system -> derivation) -> derivation
  # forEachSystem :: (system -> pkgs -> derivation) -> derivation
  forEachSystem = fn:
    flake-utils.lib.eachSystem systems (
      system: let
        nixpkgs =
          if (builtins.match ".*darwin" system != null)
          then macosPkgs
          else nixosPkgs;
      in
        fn nixpkgs.legacyPackages.${system}
    );

  # Utility function to construct a package set based on the given system
  # along with the shared `nixpkgs` configuration defined in this repo.
  mkPkgsFor = system: pkgset:
    import pkgset {
      inherit system;
      config = import ../config/shared/nixpkgs.nix;
    };

  # Utility function to construct a default `specialArgs` attrset (for NixOS &
  # nix-darwin deployments) pre-populated with:
  # - flake `inputs`, passed through more-or-less unmodified
  # - stable `pkgs` for the target system
  # - `unstable` packages
  mkSpecialArgs = nixpkgs: system: {
    inputs = inputs // {inherit nixpkgs;};
    pkgs = mkPkgsFor system nixpkgs;
    unstable = mkPkgsFor system unstable;
  };

  # Utility function to construct a macOS system config for some version of
  # stable nixpkgs passed in as an argument.
  mkMacOSSystemCfgWith = stable: home: hostname: system:
    darwin.lib.darwinSystem rec {
      specialArgs = mkSpecialArgs stable system;
      modules = [
        home.darwinModules.home-manager
        {
          home-manager.extraSpecialArgs = specialArgs;
          networking.hostName = hostname;
        }
        ../modules/system/primary-user/macos.nix
        (../hosts + "/${hostname}/system.nix")
        {
          primary-user.home-manager =
            import (../hosts + "/${hostname}/user.nix");
        }
      ];
    };

  # Utility function to construct a macOS system config using the default
  # stable `macosPkgs` & `macosHome` passed in to this util module.
  mkMacOSSystemCfg = mkMacOSSystemCfgWith macosPkgs macosHome;

  # Utility function to construct a macOS user config.
  mkMacOSUserCfg = hostname: system:
    macosHome.lib.homeManagerConfiguration rec {
      extraSpecialArgs = mkSpecialArgs macosPkgs system;
      inherit (extraSpecialArgs) pkgs;
      modules = [
        (../hosts + "/${hostname}/user.nix")
      ];
    };

  # Utility function to construct a NixOS system config for some version of
  # stable nixpkgs passed in as an argument.
  mkNixOSSystemCfgWith = stable: home: hostname: system:
    stable.lib.nixosSystem rec {
      inherit system;
      specialArgs = mkSpecialArgs stable system;
      modules = [
        stable.nixosModules.notDetected
        home.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = specialArgs;
          networking.hostName = hostname;
        }
        ../modules/system/primary-user/nixos.nix
        {
          primary-user.home-manager =
            import (../hosts + "/${hostname}/user.nix");
        }
        (../hosts + "/${hostname}/system.nix")
      ];
    };

  # Utility function to construct a NixOS system config using the default \
  # stable `nixosPkgs` & `nixosHome` passed in to this util module.
  mkNixOSSystemCfg = mkNixOSSystemCfgWith nixosPkgs nixosHome;

  # Utility function to construct a NixOS/Linux user config.
  mkLinuxUserCfg = hostname: system:
    nixosHome.lib.homeManagerConfiguration rec {
      extraSpecialArgs = mkSpecialArgs nixosPkgs system;
      pkgs = extraSpecialArgs.pkgs;
      modules = [
        (../hosts + "/${hostname}/user.nix")
      ];
    };
}
