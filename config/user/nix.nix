{
  lib,
  pkgs,
  pkgsets,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  inherit (pkgs.buildPlatform) isDarwin isAarch64;
  inherit (import ../shared/caches.nix) substituters trusted-public-keys;
in
{
  nix = {
    enable = true;
    settings = mkMerge [
      {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        inherit substituters trusted-public-keys;
      }
      # NOTE: This should allow ARM-based macOS targets to build x86 software
      # by way of Rosetta.
      (mkIf (isDarwin && isAarch64) {
        extra-platforms = [
          "aarch64-darwin"
          "x86_64-darwin"
        ];
      })
    ];

    # FIXME: Duplicated; see system-level Nix config.
    registry = {
      nixpkgs.flake = pkgsets.nixpkgs;
      unstable.flake = pkgsets.unstable;
    };
  };
}
