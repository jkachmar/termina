{ inputs, ... }:
{
  imports = [
    inputs.home.darwinModules.home-manager
    ./mixins
    ./profiles
  ];
}
