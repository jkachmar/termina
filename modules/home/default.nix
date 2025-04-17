{ lib, ... }: {
  imports = [ ./profiles ];
  home.stateVersion = "24.11";
  # Allow home-manager to manage itself by default.
  programs.home-manager.enable = lib.mkDefault true;
}
