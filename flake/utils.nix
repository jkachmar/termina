inputs @ {
  # Nix package sets.
  macosPkgs,
  nixosPkgs,
  unstable,
  # 3rd-party utilities.
  darwin,
  macosHome,
  nixosHome,
  ...
}: rec {
  # Utility function to construct a package set based on the given system
  # along with the shared `nixpkgs` configuration defined in this repo.
  mkPkgsFor = system: pkgset:
    import pkgset {
      inherit system;
      config = import ../config/shared/nixpkgs.nix;
    };

  # Utility function to construct a macOS system config.
  mkMacOSSystemCfg = hostname: system:
    darwin.lib.darwinSystem rec {
      specialArgs = {
        inputs = inputs // {nixpkgs = macosPkgs;};
        pkgs = mkPkgsFor system macosPkgs;
        unstable = mkPkgsFor system unstable;
      };
      modules = [
        macosHome.darwinModules.home-manager
        {
          home-manager.extraSpecialArgs = specialArgs;
          networking.hostName = hostname;
        }
        (../hosts + "/${hostname}/system.nix")
      ];
    };

  # Utility function to construct a macOS user config.
  mkMacOSHomeCfg = hostname: system:
    macosHome.lib.homeManagerConfiguration {
      extraSpecialArgs = {
        inputs = inputs // {nixpkgs = macosPkgs;};
        unstable = mkPkgsFor system unstable;
      };
      pkgs = mkPkgsFor system macosPkgs;
      modules = [
        (../hosts + "/${hostname}/home.nix")
      ];
    };

  # Utility function to construct a NixOS system config.
  mkNixOSSystemCfg = hostname: system:
    nixosPkgs.lib.nixosSystem rec {
      inherit system;
      specialArgs = {
        inputs = inputs // {nixpkgs = nixosPkgs;};
        pkgs = mkPkgsFor system nixosPkgs;
        unstable = mkPkgsFor system unstable;
      };
      modules = [
        nixosPkgs.nixosModules.notDetected
        nixosHome.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = specialArgs;
          networking.hostName = hostname;
        }
        (../hosts + "/${hostname}/home.nix")
      ];
    };

  # Utility function to construct a NixOS/Linux user config.
  mkLinuxHomeCfg = hostname: system: {
  };
}
