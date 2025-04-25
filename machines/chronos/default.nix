{
  inputs,
  lib,
  self,
  withSystem,
  ...
}:
{
  flake.diskoConfigurations = {
    hrodreptus = import ./disks/hrodreptus.nix;
    titan = import ./disks/titan.nix;
  };
  flake.nixosConfigurations.chronos = withSystem "x86_64-linux" (
    { unstable, system, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs self unstable; };
      modules = [
        {
          networking.hostName = "chronos";
          nixpkgs.hostPlatform = system;
        }
        ./system.nix
      ];
    }
  );
  flake.homeConfigurations.chronos = withSystem "x86_64-linux" (
    {
      pkgs,
      unstable,
      ...
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs pkgs unstable; };
      modules = [
        {
          imports = [ ../../modules/home ];
          profiles = {
            fonts.enable = false;
            gpg.enable = false;
            ssh.yubikey = false;
            vcs.signing = false;
          };
        }
      ];
    }
  );
}
