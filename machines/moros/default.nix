{
  inputs,
  lib,
  self,
  withSystem,
  ...
}:
{
  flake.homeConfigurations.moros = withSystem "aarch64-darwin" (
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
        profiles.vcs.signing = true;
      }];
    }
  );

  flake.darwinConfigurations.moros = withSystem "aarch64-darwin" (
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
          networking.hostName = "moros";
          nixpkgs.hostPlatform = system;
          profiles.homebrew.personal = true;
        }
      ];
    }
  );
}
