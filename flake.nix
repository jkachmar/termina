{
  #############################################################################
  description = "jkachmar's personal dotfiles and machine configurations.";

  #############################################################################
  outputs = inputs: let
    utils = (import ./utils/flakes.nix) inputs;
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

        oasis = utils.mkNixOSSystemCfgWith {
          hostname = "oasis";
          system = "x86_64-linux";
          extraModules = [
            inputs.disko.nixosModules.disko
            inputs.impermanence.nixosModule
          ];
        };

        star-platinum = utils.mkNixOSSystemCfg "star-platinum" "x86_64-linux";
      };

      ########################
      # USER CONFIGURATIONS. #
      ########################
      userConfigurations = {
        # macOS user configurations.
        crazy-diamond = utils.mkMacOSUserCfg "crazy-diamond" "aarch64-darwin";
        manhattan-transfer = utils.mkMacOSUserCfg "manhattan-transfer" "aarch64-darwin";

        # Linux user configurations.
        #
        # NOTE: $WORK configures my development VM automatically & assigns it a
        # hostname based off of my username.
        jkachmar = utils.mkLinuxUserCfg "highway-star" "x86_64-linux";
      };
    }
    # Any system-agnostic stuff, pretty much just `devShells` for now.
    #
    # NOTE: `utils.forEachSystem` implicitly selects between `macosPkgs` and
    # `nixosPkgs` depending on the system being built via a silly regex match.
    // utils.forEachSystem (pkgs: {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs;
          [
            alejandra
            (writeShellApplication {
              name = "user";
              text = builtins.readFile ./scripts/user;
            })
          ]
          ++ lib.optionals buildPlatform.isDarwin [
            (writeShellApplication {
              name = "rebuild";
              text = builtins.readFile ./scripts/darwin;
            })
          ]
          ++ lib.optionals buildPlatform.isLinux [
            inputs.disko.packages.${buildPlatform.system}.disko
            rng-tools
          ];
      };
    }));

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
    macosPkgs.url = "github:nixos/nixpkgs/nixpkgs-23.05-darwin";

    # Latest stable NixOS & Linux package set.
    nixosPkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    # Unstable (rolling-release) NixOS package set.
    #
    # NOTE: `unstable-small` indicates that a "minimum" set of unstable
    # packages passes CI; there may still be binary cache misses and other
    # issues, but it's a good compromise between `trunk` and `nixosPkgs`.
    unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";

    # # Tip of the unstable (rolling-release) NixOS package set.
    # #
    # # NOTE: `unstable-small` indicates that a "minimum" set of unstable
    # # packages passes CI; `trunk` makes no such guarantees, but can be useful
    # # to quickly incorporate changes that have been incorporated very recently.
    # trunk.url = "github:nixos/nixpkgs";

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
      inputs.nixpkgs.follows = "unstable";
      url = "github:nix-community/disko";
    };

    flake-utils.url = "github:numtide/flake-utils";

    impermanence.url = "github:nix-community/impermanence";

    # Declarative user configuration for macOS systems.
    macosHome = {
      inputs = {
        nixpkgs.follows = "macosPkgs";
      };
      # NOTE: Update this when `macosPkgs` is updated to a new stable release!
      url = "github:nix-community/home-manager/release-23.05";
    };

    # Declarative user configuration for NixOS & Linux systems.
    nixosHome = {
      inputs = {
        nixpkgs.follows = "nixosPkgs";
      };
      # NOTE: Update this when `nixosPkgs` is updated to a new stable release!
      url = "github:nix-community/home-manager/release-23.05";
    };
  };
}
