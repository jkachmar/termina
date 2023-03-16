{
  imports = [
    ./applications.nix
    ./dock.nix
    ./inputs.nix
  ];

  nix.configureBuildUsers = true;
  services.nix-daemon.enable = true;
}
