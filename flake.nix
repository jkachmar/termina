{
  #############################################################################
  description = "";

  #############################################################################
  inputs = {
    # Nix package sets and other official sources.
    flakeRegistry = {
      flake = false;
      url = "github:nixos/flake-registry/master";
    };
    nixpkgs.url = "github:nixos/nixpkgs/22.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    trunk.url = "github:nixos/nixpkgs/master";

    # Nix flake utilities.
    flake-parts = {
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils/master";

    # Configuration & deployment.
    colmena = {
      inputs.nixpkgs.follows = "unstable";
      inputs.stable.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
      url = "github:zhaofengli/colmena/main";
    };
    # NOTE: Use 'colmena' cachix binary cache & skip the "follows" stuff.
    #
    # Their CI builds {aarch64,x86_64}-{darwin,linux} which is all we need.
    # colmena.url = "github:zhaofengli/colmena/main";
    darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:lnl7/nix-darwin";
    };
    home = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-22.05";
    };
  };

  #############################################################################
  outputs = inputs @ {
    self,
    darwin,
    flake-parts,
    flake-utils,
    nixpkgs,
    unstable,
    trunk,
    ...
  }: let
    inherit (flake-parts.lib) mkFlake;
    inherit (flake-utils.lib) system;
    linuxSystems = with system; [
      aarch64-linux
      x86_64-linux
    ];
    macosSystems = with system; [
      aarch64-darwin
      x86_64-darwin
    ];
    systems = linuxSystems ++ macosSystems;
  in
    mkFlake {inherit self;} ({withSystem, ...}: {
      inherit systems;
      perSystem = {
        pkgs,
        inputs',
        ...
      }: {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            alejandra
            inputs'.colmena.packages.colmena
          ];
        };
      };

      flake = {
        colmena = {};
        # 'crazy-diamond'
        darwinConfigurations.crazy-diamond = withSystem system.x86_64-darwin ({pkgs, system, ...}:
          inputs.darwin.lib.darwinSystem {
            inherit system;
            specialArgs.inputs = inputs;
            modules = [];
          });
        homeConfigurations.crazy-diamond = withSystem system.x86_64-darwin ({pkgs, ...}:
          inputs.home.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [];
          });
        # 'enigma'
        nixosConfigurations.enigma = inputs.nixpkgs.lib.nixosSystem {
          system = system.x86_64-linux;
          modules = [];
        };
      };
    });
}
