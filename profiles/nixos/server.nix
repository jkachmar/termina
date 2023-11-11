{...}: {
  imports = [
    ./node.nix # Every server inherits from the node profile.
    ../../modules/nixos/security/acme.nix
    ../../modules/nixos/services/dnscrypt-proxy.nix
    ../../modules/nixos/services/homebridge.nix
    ../../modules/nixos/services/linkding.nix
    ../../modules/nixos/services/nginx.nix
    ../../modules/nixos/services/pihole.nix
    ../../modules/nixos/services/plex
  ];

  programs.mosh.enable = true;
}
