{ inputs, ... }:
let
  # Utility function to construct a package set based on the given system
  # along with the shared `nixpkgs` configuration defined in this repo.
  mkPkgsFor =
    system: pkgset:
    import pkgset {
      inherit system;
      config = import ../config/shared/nixpkgs.nix;
    };
in
{
  perSystem =
    { system, ... }:
    {
      _module.args = rec {
        # Provide un-imported package set paths for reference in other modules.
        pkgsets = {
          inherit (inputs) unstable;
          # Select the Nix package path based on the system being managed.
          nixpkgs =
            if (builtins.match ".*darwin" system != null) then inputs.macosPkgs else inputs.stablePkgs;
        };

        # Import the default Nix package set with the common config.
        pkgs = mkPkgsFor system pkgsets.nixpkgs;

        # Import the unstable Nix package set with the common config.
        unstable = mkPkgsFor system pkgsets.unstable;

        # Select the home-manager input based on the system being managed.
        homeManager =
          if (builtins.match ".*darwin" system != null) then inputs.macosHome else inputs.linuxHome;
      };
    };
}
