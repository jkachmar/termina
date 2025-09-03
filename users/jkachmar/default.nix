{ inputs, self, ... }:
{
  flake = {
    darwinModules.jkachmar = {
      imports = [ ./darwin.nix ];
    };
    nixosModules.jkachmar = {
      imports = [ ./nixos.nix ];
    };
    homeModules.jkachmar = {
      imports = self.internal.modules.home ++ [
        ./home.nix
      ];
    };
  };
}
