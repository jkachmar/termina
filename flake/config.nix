{inputs, ...}: let
  inherit (import ./utils.nix) mkPkgsFor;
in {
  perSystem = {system, ...}: {
    # Ensure that the default Nix package set is selected based on the
    # underlying OS & is given the default config used everywhere else.
    _module.args.pkgs =
      if (builtins.match ".*darwin" system != null)
      then mkPkgsFor system inputs.macosPkgs
      else mkPkgsFor system inputs.stablePkgs;
    # Ensure that the unstable Nix package set is given the same config used
    # everywhere else.
    _module.args.unstable = mkPkgsFor system inputs.unstable;
  };
}
