{
  #############################################################################
  description = "jkachmar's personal dotfiles and machine configurations.";

  #############################################################################
  inputs = {
    #################
    # PACKAGE SETS. #
    #################
    # Stable macOS package set; pinned to the latest 22.05 release.
    #
    # `darwin` is used to indicate the most up-to-date stable packages tested
    # against macOS.
    #
    # XXX: Temporarily pinning this to unstable for new home-manager stuff.
    # macosPkgs.url = "github:nixos/nixpkgs/nixpkgs-22.05-darwin";
    macosPkgs.url = "github:nixos/nixpkgs";

    # Stable NixOS package set; pinned to the latest 22.05 release.
    #
    # XXX: Temporarily pinning this to unstable for new home-manager stuff.
    # nixosPkgs.url = "github:nixos/nixpkgs/nixos-22.05";

    nixosPkgs.url = "github:nixos/nixpkgs";

    # Unstable (rolling-release) NixOS package set.
    unstable.url = "github:nixos/nixpkgs";

    ##############
    # UTILITIES. #
    ##############
    # Declarative, NixOS-style configuration for macOS.
    darwin = {
      inputs.nixpkgs.follows = "macosPkgs";
      url = "github:lnl7/nix-darwin";
    };

    # Declarative user configuration for macOS systems.
    macosHome = {
      inputs.nixpkgs.follows = "macosPkgs";
      url = "github:nix-community/home-manager";
    };

    # Declarative user configuration for NixOS systems.
    nixosHome = {
      inputs.nixpkgs.follows = "nixosPkgs";
      url = "github:nix-community/home-manager/release-22.05";
    };
  };

  #############################################################################
  outputs = inputs@{ self, darwin, macosHome, macosPkgs, nixosPkgs, unstable, ... }:
    let
      # Utility function to construct a package set based on the given system
      # along with the shared `nixpkgs` configuration defined in this repo.
      mkPkgsFor = system: pkgset:
        import pkgset {
          inherit system;
          config = import ./config/nixpkgs.nix;
        };

      # Utility function to construct a macOS system configuration.
      mkMacOSSystemCfg = hostname: system: darwin.lib.darwinSystem {
        modules = [(./hosts + "/${hostname}/system.nix")];
        specialArgs = {
          inputs = inputs // {
            nixpkgs = macosPkgs;
          };
          pkgs = mkPkgsFor system macosPkgs;
          unstable = mkPkgsFor system unstable;
        };
      };

      # Utility function to construct a macOS home configuration.
      mkMacOSHomeCfg = hostname: system: macosHome.lib.homeManagerConfiguration {
        pkgs = mkPkgsFor system macosPkgs;
        modules = [(./hosts + "/${hostname}/home.nix")];
      };

      # Utility function to construct a NixOS system configuration.
      mkNixOSSystemCfg = hostname: system: nixosPkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixosPkgs.nixosModules.notDetected
          (./hosts + "/${hostname}/home.nix")
        ];
        specialArgs = {
          inherit inputs;
          pkgs = mkPkgsFor system nixosPkgs;
          unstable = mkPkgsFor system inputs.unstable;
        };
      };

      # Utility function to construct a NixOS home configuration.
      mkLinuxHomeCfg = hostname: system: {
      };
    in
    {
      ##########################
      # SYSTEM CONFIGURATIONS. #
      ##########################
      # macOS system configurations.
      darwinConfigurations = {
        crazy-diamond = mkMacOSSystemCfg "crazy-diamond" "x86_64-darwin";
      };

      # NixOS system configurations.
      nixosConfigurations = {
        enigma = mkNixOSSystemCfg "enigma" "x86_64-linux";
        kraftwerk = mkNixOSSystemCfg "kraftwerk" "x86_64-linux";
        star-platinum = mkNixOSSystemCfg "star-platinum" "x86_64-linux";
      };

      ########################
      # USER CONFIGURATIONS. #
      ########################
      homeConfigurations = {
        # macOS home configurations.
        crazy-diamond = mkMacOSHomeCfg "crazy-diamond" "x86_64-darwin";

        # Linux home configurations.
      };
    };
}
