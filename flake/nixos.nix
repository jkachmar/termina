{
  inputs,
  self,
  withSystem,
  ...
}: let
  # Utility function to construct a NixOS system configuration with optional
  # module overrides.
  mkNixOSConfigWith = {
    hostname,
    system,
    extraModules ? [],
  }:
    withSystem system ({
      pkgsets,
      pkgs,
      unstable,
      homeManager,
      ...
    }:
      pkgsets.nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = {inherit inputs pkgsets pkgs unstable;};
        modules =
          extraModules
          ++ [
            pkgsets.nixpkgs.nixosModules.notDetected
            homeManager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = specialArgs;
              networking.hostName = hostname;
            }
            ../modules/nixos/primary-user.nix
            {primary-user.home-manager = import (../hosts + "/${hostname}/user.nix");}
            (../hosts + "/${hostname}/system.nix")
          ];
      });

  # Utility function to construct a NixOS system config without specifying any
  # additional modules.
  mkNixOSConfig = hostname: system:
    mkNixOSConfigWith {inherit hostname system;};
in {
  flake = {
    nixosConfigurations = {
      enigma = mkNixOSConfig "enigma" "x86_64-linux";
      star-platinum = mkNixOSConfig "star-platinum" "x86_64-linux";
      # NOTE: Testing `disko` & `impermanence` again.
      tatl = mkNixOSConfigWith {
        hostname = "tatl";
        system = "x86_64-linux";
        extraModules = [
          inputs.disko.nixosModules.disko
          inputs.microvm.nixosModules.host
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
