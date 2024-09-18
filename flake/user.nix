{ inputs, outputs, withSystem, ... }:
let
  inherit (import ./utils.nix) mkSpecialArgs;

  # Utility function to construct an OS-agnostic user-level config.
  mkUserConfig =
    hostname: system:
    withSystem system (
      {
        pkgsets,
        pkgs,
        unstable,
        homeManager,
        ...
      }:
      homeManager.lib.homeManagerConfiguration rec {
        inherit pkgs;
        extraSpecialArgs = {
          inherit pkgsets pkgs unstable;
        };
        modules = [
          (../hosts + "/${hostname}/user.nix")
          # FIXME: Workaround for the fact that 'NIX_PATH' isn't set when not
          # using the system config.
          (
            { lib, ... }:
            {
              home.sessionVariables.NIX_PATH = lib.concatStringsSep ":" [
                "nixpkgs=${pkgsets.nixpkgs}"
                "unstable=${pkgsets.unstable}"
              ];
            }
          )
        ];
      }
    );
in
{
  flake = {
    userConfigurations = {
      # macOS user configurations.
      crazy-diamond = mkUserConfig "crazy-diamond" "aarch64-darwin";
      manhattan-transfer = mkUserConfig "manhattan-transfer" "aarch64-darwin";

      # Linux user configurations.
      #
      # NOTE: $WORK configures my development VM automatically & assigns it a
      # hostname based off of my username.
      jkachmar = mkUserConfig "highway-star" "x86_64-linux";
    };

    # Expose the activation package created by `home-manager`, so it can be
    # realized (and possibly applied) directly from the command line.
    packages = with outputs.userConfigurations; {
      aarch64-darwin.crazy-diamond-user = crazy-diamond.activationPackage;
      aarch64-darwin.manhattan-transfer-user = manhattan-transfer.activationPackage;
      x86_64-linux.jkachmar-user = jkachmar.activationPackage;
    };
  };
}
