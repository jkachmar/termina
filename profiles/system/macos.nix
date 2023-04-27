{
  imports = [
    ../../config/system/macos/applications.nix
    ../../config/system/macos/dock.nix
    ../../config/system/macos/inputs.nix
  ];

  nix.configureBuildUsers = true;
  services.nix-daemon.enable = true;
}
