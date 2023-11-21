{lib, ...}: {
  # Modules common across all NixOS nodes.
  imports = [
    ./primary-user.nix
    ./security
    ./services
    ./systemd-boot.nix
    ./virtualisation
  ];

  users.groups.downloads.gid = lib.mkDefault 1010;
}
