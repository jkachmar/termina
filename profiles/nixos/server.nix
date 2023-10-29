{
  imports = [
    ./node.nix # Every server inherits from the node profile.
    ../../modules/nixos/services/homebridge.nix
    ../../modules/nixos/services/linkding.nix
  ];

  programs.mosh.enable = true;
}
