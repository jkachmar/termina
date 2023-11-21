{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/profiles/hardened.nix" # Hardened OS defaults.
    ../../config/system/nix.nix
    ../../config/system/devtools.nix
    ../../modules/nixos
  ];

  # The hardened profile disables this by default but it's too useful.
  security.allowSimultaneousMultithreading = true;
  security.ssh-agent.enable = true;
  services.fail2ban.enable = true;
  services.openssh.enable = true;
  time.timeZone = lib.mkDefault "America/New_York";
  virtualisation.podman.enable = true;
}
