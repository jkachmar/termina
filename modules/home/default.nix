{ lib, ... }:
{
  imports = [ ./profiles ];
  home.stateVersion = "25.05";
  # Allow home-manager to manage itself by default.
  programs.home-manager.enable = lib.mkDefault true;
}
