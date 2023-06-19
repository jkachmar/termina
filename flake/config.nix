{inputs, ...}: let
  inherit (import ./utils.nix) mkPkgsFor;
in {
  perSystem = {system, ...}: {
    _module.args.pkgs =
      if (builtins.match ".*darwin" system != null)
      then mkPkgsFor system inputs.macosPkgs
      else mkPkgsFor system inputs.stablePkgs;
  };
}
