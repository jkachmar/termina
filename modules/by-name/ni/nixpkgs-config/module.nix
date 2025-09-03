{ self, ... }:

{
  nixpkgs = {
    config = self.nixpkgs-config;
    overlays = [ self.overlays.stable ];
  };
}
