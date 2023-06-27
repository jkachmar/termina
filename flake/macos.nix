{
  inputs,
  self,
  withSystem,
  ...
}: let
  inherit (inputs) darwin;

  # Utility function to construct a macOS system config.
  mkMacOSConfig = hostname: system:
    withSystem system
    ({
      pkgsets,
      pkgs,
      unstable,
      homeManager,
      ...
    }:
      darwin.lib.darwinSystem rec {
        specialArgs = {
          inherit pkgsets pkgs unstable;
          # XXX: `nix-darwin` requires that `inputs` have a `nixpkgs` attribute.
          inputs =
            inputs
            // {
              inherit (pkgsets) nixpkgs;
            };
        };
        modules = [
          homeManager.darwinModules.home-manager
          {
            home-manager.extraSpecialArgs = specialArgs;
            networking.hostName = hostname;
          }
          ../modules/system/primary-user/macos.nix
          (../hosts + "/${hostname}/system.nix")
          {primary-user.home-manager = import (../hosts + "/${hostname}/user.nix");}
        ];
      });
in {
  flake = {
    darwinConfigurations = {
      crazy-diamond = mkMacOSConfig "crazy-diamond" "aarch64-darwin";
    };

    # Expose the activation package created by `nix-darwin`, so it can be
    # realized (and possibly applied) directly from the command line.
    packages = with self.outputs.darwinConfigurations; {
      aarch64-darwin.crazy-diamond-system =
        crazy-diamond.config.system.build.toplevel;
    };
  };
}
