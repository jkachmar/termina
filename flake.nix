{
  description = ''
    punishment is all that is left for souls such as these; no more chance of
    rehabilitation, only suffering
  '';

  outputs =
    inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      imports = [
        ./modules/flake
        ./machines
      ];
      flake = {
        # Expose the default nixpkgs config that's shared by all package sets.
        nixpkgs-config = {
          allowUnfreePredicate = pkg: false;
        };
        # Expose different overlays for the 'stable' & 'unstable' package sets.
        overlays = {
          stable = import ./overlays/stable.nix;
          unstable = import ./overlays/unstable.nix;
        };
      };
    };

  inputs = {
    # Package sets.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";

    # Use 'Lix' instead of 'CppNix' everywhere.
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # macOS system management.
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User config.
    home = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake module management.
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Autoformatting via 'nix fmt'.
    treefmt = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
    };

    # Secret management.
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # A cute theme for lots of stuff :3
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "";
        home-manager.follows = "";
        home-manager-stable.follows = "";
        nuscht-search.follows = "";
        catppuccin-v1_1.follows = "";
        catppuccin-v1_2.follows = "";
      };
    };
  };
}
