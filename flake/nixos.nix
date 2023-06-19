{
  inputs,
  self,
  ...
}: let
  inherit (inputs) linuxHome stablePkgs;
  inherit (import ./utils.nix) mkSpecialArgs;

  # Utility function to construct a NixOS system config for some version of
  # stable nixpkgs passed in as an argument.
  #
  # NOTE: Some code duplication with `mkMacOSSystemCfgWith`.
  mkNixOSSystemCfgWith = {
    stable ? stablePkgs,
    homeManager ? linuxHome,
    extraModules ? [],
    hostname,
    system,
  }:
    stable.lib.nixosSystem rec {
      inherit system;
      specialArgs = mkSpecialArgs stable system;
      modules =
        extraModules
        ++ [
          stable.nixosModules.notDetected
          homeManager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = specialArgs;
            networking.hostName = hostname;
          }
          ../modules/system/primary-user/nixos.nix
          {primary-user.home-manager = import (../hosts + "/${hostname}/user.nix");}
          (../hosts + "/${hostname}/system.nix")
        ];
    };

  # Utility function to construct a NixOS system config using the default
  # `stablePkgs` & `linuxHome` arguments.
  mkNixOSSystemCfg = hostname: system:
    mkNixOSSystemCfgWith {inherit hostname system;};
in {
  flake = {
    nixosConfigurations = {
      enigma = mkNixOSSystemCfg "enigma" "x86_64-linux";
      star-platinum = mkNixOSSystemCfg "star-platinum" "x86_64-linux";
      # NOTE: Testing `disko` & `impermanence` again.
      tatl = mkNixOSSystemCfgWith {
        hostname = "tatl";
        system = "x86_64-linux";
        extraModules = [
          inputs.disko.nixosModules.disko
          inputs.impermanence.nixosModule
        ];
      };
    };

    # Expose the activation package created by `nixos-rebuild`, so it can be
    # realized (and possibly applied) directly from the command line.
    packages = with self.outputs.nixosConfigurations; {
      x86_64-linux.tatl-system =
        tatl.config.system.build.toplevel;
    };
  };
}
