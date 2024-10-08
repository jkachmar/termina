{
  #############################################################################
  description = "jkachmar's personal dotfiles and machine configurations.";

  #############################################################################
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./flake ];
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    };

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
    macosPkgs.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";

    # Latest stable Nix package set.
    stablePkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    # Unstable (rolling-release) Nix package set.
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

    deploy-rs = {
      inputs.nixpkgs.follows = "unstable";
      url = "github:serokell/deploy-rs";
    };

    # Declarative disk partitioning for NixOS.
    disko = {
      inputs.nixpkgs.follows = "stablePkgs";
      url = "github:nix-community/disko";
    };

    # Module system for Nix flakes.
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Modules for persistence when mounting root & home on tmpfs.
    impermanence.url = "github:nix-community/impermanence";

    # Declarative user configuration for Linux systems.
    linuxHome = {
      inputs.nixpkgs.follows = "stablePkgs";
      # NOTE: Update this when `stablePkgs` is updated to a new stable release!
      url = "github:nix-community/home-manager/release-24.05";
    };

    # Declarative user configuration for macOS systems.
    macosHome = {
      inputs.nixpkgs.follows = "macosPkgs";
      # NOTE: Update this when `macosPkgs` is updated to a new stable release!
      url = "github:nix-community/home-manager/release-24.05";
    };

    # Lightweight NixOS VMs.
    microvm = {
      inputs.nixpkgs.follows = "stablePkgs";
      url = "github:astro/microvm.nix";
    };

    nixos-anywhere = {
      url = "github:numtide/nixos-anywhere";
      inputs = {
        disko.follows = "disko";
        flake-parts.follows = "flake-parts";
        nixos-stable.follows = "stablePkgs";
        nixpkgs.follows = "stablePkgs";
        treefmt-nix.follows = "treefmt";
      };
    };

    # Autoformatting via `nix fmt`.
    treefmt = {
      inputs.nixpkgs.follows = "stablePkgs";
      url = "github:numtide/treefmt-nix";
    };
  };
}
