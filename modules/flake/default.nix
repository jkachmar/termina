{ inputs, self, ... }:
{
  imports = [
    ./darwinConfigurations.nix
    # FIXME: Import this module from the home-manager input when we update to 25.05.
    ./homeConfigurations.nix
    ./treefmt.nix
  ];

  perSystem =
    { system, ... }:
    {
      _module.args = {
        pkgs = import inputs.nixpkgs {
          inherit system;
          config = self.nixpkgs-config;
          overlays = [ self.overlays.stable ];
        };
        unstable = import inputs.unstable {
          inherit system;
          config = self.nixpkgs-config;
          overlays = [ self.overlays.unstable ];
        };
      };
    };
}
