{
  inputs,
  self,
  ...
}: let
  inherit (inputs) linuxHome macosHome unstable;
  inherit (import ./utils.nix) mkSpecialArgs;

  mkUserCfg = {
    hostname,
    system,
    nixpkgs,
    homeManager,
  }:
    homeManager.lib.homeManagerConfiguration rec {
      extraSpecialArgs = mkSpecialArgs inputs nixpkgs system;
      inherit (extraSpecialArgs) pkgs;
      modules = [
        (../hosts + "/${hostname}/user.nix")
        # FIXME: Workaround for the fact that 'NIX_PATH' isn't set when not
        # using the system config.
        ({
          inputs,
          lib,
          ...
        }: {
          home.sessionVariables.NIX_PATH = lib.concatStringsSep ":" [
            "nixpkgs=${nixpkgs}"
            "unstable=${inputs.unstable}"
          ];
        })
      ];
    };
  mkLinuxUserCfg = hostname: system:
    mkUserCfg {
      inherit hostname system;
      homeManager = inputs.linuxHome;
      nixpkgs = inputs.stablePkgs;
    };

  mkMacOSUserCfg = hostname: system:
    mkUserCfg {
      inherit hostname system;
      homeManager = inputs.macosHome;
      nixpkgs = inputs.macosPkgs;
    };
in {
  flake = {
    userConfigurations = {
      # macOS user configurations.
      crazy-diamond = mkMacOSUserCfg "crazy-diamond" "aarch64-darwin";
      manhattan-transfer = mkMacOSUserCfg "manhattan-transfer" "aarch64-darwin";

      # Linux user configurations.
      #
      # NOTE: $WORK configures my development VM automatically & assigns it a
      # hostname based off of my username.
      jkachmar = mkLinuxUserCfg "highway-star" "x86_64-linux";
    };

    # Expose the activation package created by `home-manager`, so it can be
    # realized (and possibly applied) directly from the command line.
    packages = with self.outputs.userConfigurations; {
      aarch64-darwin.crazy-diamond-user =
        crazy-diamond.activationPackage;
      aarch64-darwin.manhattan-transfer-user =
        manhattan-transfer.activationPackage;
      x86_64-linux.highway-star =
        jkachmar.activationPackage;
    };
  };
}
