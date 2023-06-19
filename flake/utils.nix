rec {
  # Utility function to construct a package set based on the given system
  # along with the shared `nixpkgs` configuration defined in this repo.
  mkPkgsFor = system: pkgset:
    import pkgset {
      inherit system;
      config = import ../config/shared/nixpkgs.nix;
    };

  # Utility function to construct a default `specialArgs` attrset (for NixOS &
  # nix-darwin deployments) pre-populated with:
  # - flake `inputs`, passed through more-or-less unmodified
  # - stable `pkgs` for the target system
  # - `unstable` packages
  mkSpecialArgs = inputs: nixpkgs: system: {
    inputs = inputs // {inherit nixpkgs;};
    pkgs = mkPkgsFor system nixpkgs;
    unstable = mkPkgsFor system inputs.unstable;
  };
}
