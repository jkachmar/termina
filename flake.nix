{
  #############################################################################
  description = "jkachmar's personal dotfiles and machine configurations.";

  #############################################################################
  inputs = {
    #################
    # PACKAGE SETS. #
    #################
    # Latest stable macOS package set.
    #
    # NOTE: `darwin` indicates that this channel passes CI on macOS builders;
    # this should increase the binary cache hit rate, but may result in it
    # lagging behind the equivalent NixOS/Linux package set.
    macosPkgs.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";

    # Latest stable NixOS & Linux package set.
    nixosPkgs.url = "github:nixos/nixpkgs/nixos-22.11";

    # Unstable (rolling-release) NixOS package set.
    #
    # NOTE: `unstable-small` indicates that a "minimum" set of unstable
    # packages passes CI; there may still be binary cache misses and other
    # issues, but it's a good compromise between `trunk` and `stable`.
    unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";

    ##############
    # UTILITIES. #
    ##############
    # Declarative, NixOS-style configuration for macOS.
    darwin = {
      inputs.nixpkgs.follows = "macosPkgs";
      url = "github:lnl7/nix-darwin";
    };

    # Declarative disk partitioning for NixOS.
    disko = {
      inputs.nixpkgs.follows = "nixosPkgs";
      url = "github:nix-community/disko";
    };

    flake-utils.url = "github:numtide/flake-utils";

    # Declarative user configuration for macOS systems.
    macosHome = {
      inputs = {
        nixpkgs.follows = "macosPkgs";
        utils.follows = "flake-utils";
      };
      url = "github:nix-community/home-manager/release-22.11";
    };

    # Declarative user configuration for NixOS & Linux systems.
    nixosHome = {
      inputs = {
        nixpkgs.follows = "nixosPkgs";
        utils.follows = "flake-utils";
      };
      url = "github:nix-community/home-manager/release-22.11";
    };
  };

  #############################################################################
  outputs = inputs: let
    utils = (import ./flake/utils.nix) inputs;
  in ({
      ##########################
      # SYSTEM CONFIGURATIONS. #
      ##########################
      # macOS system configurations.
      darwinConfigurations = {
        crazy-diamond = utils.mkMacOSSystemCfg "crazy-diamond" "aarch64-darwin";
      };

      # NixOS system configurations.
      nixosConfigurations = {
        enigma = utils.mkNixOSSystemCfg "enigma" "x86_64-linux";
        kraftwerk = utils.mkNixOSSystemCfg "kraftwerk" "x86_64-linux";
        star-platinum = utils.mkNixOSSystemCfg "star-platinum" "x86_64-linux";
      };

      ########################
      # USER CONFIGURATIONS. #
      ########################
      homeConfigurations = {
        # macOS home configurations.
        crazy-diamond = utils.mkMacOSHomeCfg "crazy-diamond" "aarch64-darwin";

        # Linux home configurations.
      };
    }
    // utils.forEachSystem (pkgs: {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs;
          [
            alejandra
            (writeShellApplication {
              name = "home";
              text = builtins.readFile ./scripts/home;
            })
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.targetPlatform.isDarwin [
            (writeShellApplication {
              name = "rebuild";
              text = builtins.readFile ./scripts/darwin;
            })
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.targetPlatform.isDarwin [
          ];
      };
    }));
}
