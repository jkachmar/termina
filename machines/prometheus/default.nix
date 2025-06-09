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
      modules = [
        {
          imports = [ ../../modules/home ];
          profiles.vcs = {
            email = "j@mercury.com";
            signing = true;
          };
        }
      ];
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
          nix.linux-builder = {
            enable = false;
            package = pkgs.darwin.linux-builder-x86_64;
            # ephemeral = true;
            systems = [
              "x86_64-linux"
              "aarch64-linux"
            ];
          };
          launchd.daemons.linux-builder = {
            serviceConfig = {
              StandardOutPath = "/var/log/darwin-builder.log";
              StandardErrorPath = "/var/log/darwin-builder.log";
            };
          };
        }
      ];
    }
  );
}
