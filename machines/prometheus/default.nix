{
  inputs,
  lib,
  self,
  withSystem,
  ...
}:
{
  flake.homeConfigurations.prometheus = withSystem "aarch64-darwin" (
    {
      pkgs,
      unstable,
      system,
      ...
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs pkgs unstable; };
      modules = [{
        imports = [ ../../modules/home ];
        profiles.vcs = {
          email = "j@mercury.com";
          signing = true;
        };
      }];
    }
  );

  flake.darwinConfigurations.prometheus = withSystem "aarch64-darwin" (
    {
      pkgs,
      unstable,
      system,
      ...
    }:
    inputs.darwin.lib.darwinSystem {
      specialArgs = { inherit inputs self unstable; };
      modules = [
        ../../modules/system/macos
        {
          networking.hostName = "prometheus";
          nixpkgs.hostPlatform = system;
        }
      ];
    }
  );
}
