{
  inputs,
  self,
  ...
}: let
  inherit (inputs) darwin macosHome macosPkgs unstable;
  inherit (import ./utils.nix) mkSpecialArgs;

  # Utility function to construct a macOS system config for some version of
  # stable nixpkgs passed in as an argument.
  #
  # NOTE: Some code duplication with `mkNixosSystemCfgWith`.
  mkMacOSSystemCfgWith = {
    stable ? macosPkgs,
    homeManager ? macosHome,
    extraModules ? [],
    hostname,
    system,
  }:
    darwin.lib.darwinSystem rec {
      specialArgs = mkSpecialArgs inputs stable system;
      modules =
        extraModules
        ++ [
          homeManager.darwinModules.home-manager
          {
            home-manager.extraSpecialArgs = specialArgs;
            networking.hostName = hostname;
          }
          ../modules/system/primary-user/macos.nix
          (../hosts + "/${hostname}/system.nix")
          {primary-user.home-manager = import (../hosts + "/${hostname}/user.nix");}
        ];
    };

  # Utility function to construct a macOS system config using the default
  # `macosPkgs` & `macosHome` arguments.
  mkMacOSSystemCfg = hostname: system:
    mkMacOSSystemCfgWith {inherit hostname system;};
in {
  flake = {
    darwinConfigurations = {
      crazy-diamond = mkMacOSSystemCfg "crazy-diamond" "aarch64-darwin";
    };

    # Expose the activation package created by `nix-darwin`, so it can be
    # realized (and possibly applied) directly from the command line.
    packages = with self.outputs.darwinConfigurations; {
      aarch64-darwin.crazy-diamond-system =
        crazy-diamond.config.system.build.toplevel;
    };
  };
}
