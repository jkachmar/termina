{lib, ...}: {
  # Modules common across all NixOS nodes.
  imports = [
    ./primary-user.nix
    ./security
    ./services
    ./virtualisation
  ];

  # Modules common across all NixOS nodes.
  users.groups.downloads.gid = lib.mkDefault 1010;
}
