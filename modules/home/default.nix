{ inputs, ... }:
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
    ./mixins
    ./profiles
  ];
  home.stateVersion = "24.11";
}
