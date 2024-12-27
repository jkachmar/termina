{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin isLinux;
in
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    # Set '$NIX_PATH' entries to point to the local registry.
    nixPath =
      (builtins.map (pkgset: "${pkgset}=flake:${pkgset}") [
        "nixpkgs"
        "unstable"
      ])
      ++ lib.optionals isDarwin [
        "darwin=${inputs.darwin}"
      ];

    channel.enable = false; # Use flakes for everything!
    registry = {
      nixpkgs.to = {
        type = "path";
        path = pkgsets.nixpkgs;
      };
      unstable.to = {
        type = "path";
        path = pkgsets.unstable;
      };
    };
  };

  nixpkgs = {
    config = self.nixpkgs-config;
    overlays = [ self.overlays.stable ];
  };
}
