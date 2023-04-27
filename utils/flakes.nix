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

  # Utility function to iterate over a set of default systems and construct a
  # derivation for either of `macosPkgs` or `nixosPkgs` depending on whether
  # the target is Linux or macOS.
  #
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
  mkMacOSSystemCfgWith = {
    stable ? macosPkgs,
    home ? macosHome,
    extraModules ? [],
    hostname,
    system,
  }:
    darwin.lib.darwinSystem rec {
      specialArgs = mkSpecialArgs stable system;
      modules =
        extraModules
        ++ [
          home.darwinModules.home-manager
          {
            home-manager.extraSpecialArgs = specialArgs;
            networking.hostName = hostname;
          }
          ../modules/system/primary-user/macos.nix
          (../hosts + "/${hostname}/system.nix")
          {primary-user.home-manager = import (../hosts + "/${hostname}/user.nix");}
        ];
    };

  # Utility function to construct a macOS system config using the default
  # stable `macosPkgs` & `macosHome` passed in to this util module.
  mkMacOSSystemCfg = hostname: system:
    mkMacOSSystemCfgWith {inherit hostname system;};

  # Utility function to construct a macOS user config.
  #
  # TODO: Factor out common parts from `mkLinuxUserCfg`.
  mkMacOSUserCfg = hostname: system:
    macosHome.lib.homeManagerConfiguration rec {
      extraSpecialArgs = mkSpecialArgs macosPkgs system;
      inherit (extraSpecialArgs) pkgs;
      modules = [
        (../hosts + "/${hostname}/user.nix")
        # FIXME: Workaround for the fact that 'NIX_PATH' isn't set when not
        # using the system config.
        ({inputs, lib, ...}: {
          home.sessionVariables.NIX_PATH = lib.concatStringsSep ":" [
            "nixpkgs=${inputs.macosPkgs}"
            "unstable=${inputs.unstable}"
          ];
        })
      ];
    };

  # Utility function to construct a NixOS system config for some version of
  # stable nixpkgs passed in as an argument.
  mkNixOSSystemCfgWith = {
    stable ? nixosPkgs,
    home ? nixosHome,
    extraModules ? [],
    hostname,
    system,
  }:
    stable.lib.nixosSystem rec {
      inherit system;
      specialArgs = mkSpecialArgs stable system;
      modules =
        extraModules
        ++ [
          stable.nixosModules.notDetected
          home.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = specialArgs;
            networking.hostName = hostname;
          }
          ../modules/system/primary-user/nixos.nix
          {primary-user.home-manager = import (../hosts + "/${hostname}/user.nix");}
          (../hosts + "/${hostname}/system.nix")
        ];
    };

  # Utility function to construct a NixOS system config using the default \
  # stable `nixosPkgs` & `nixosHome` passed in to this util module.
  mkNixOSSystemCfg = hostname: system:
    mkNixOSSystemCfgWith {inherit hostname system;};

  # Utility function to construct a NixOS/Linux user config.
  #
  # TODO: Factor out common parts from `mkMacOSUserCfg`.
  mkLinuxUserCfg = hostname: system:
    nixosHome.lib.homeManagerConfiguration rec {
      extraSpecialArgs = mkSpecialArgs nixosPkgs system;
      inherit (extraSpecialArgs) pkgs;
      modules = [
        (../hosts + "/${hostname}/user.nix")
        # FIXME: Workaround for the fact that 'NIX_PATH' isn't set when not
        # using the system config.
        ({inputs, lib, ...}: {
          home.sessionVariables.NIX_PATH = lib.concatStringsSep ":" [
            "nixpkgs=${inputs.nixosPkgs}"
            "unstable=${inputs.unstable}"
          ];
        })
      ];
    };
}
