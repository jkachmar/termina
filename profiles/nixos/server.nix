{...}: {
  imports = [
    ./node.nix # Every server inherits from the node profile.
    ../../modules/nixos/services/dnscrypt-proxy.nix
    ../../modules/nixos/services/homebridge.nix
    ../../modules/nixos/services/linkding.nix
    ../../modules/nixos/services/nginx.nix
    ../../modules/nixos/services/pihole.nix
  ];

  programs.mosh.enable = true;
}
