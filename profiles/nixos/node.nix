{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/profiles/hardened.nix" # Hardened OS defaults.
    ./base.nix # Every node inherits from the base profile.
    ../../modules/nixos
    ../../config/system/systemd-boot.nix
  ];

  # The hardened profile disables this by default but it's too useful.
  security.allowSimultaneousMultithreading = true;
  security.ssh-agent.enable = true;
  services.fail2ban.enable = true;
  services.openssh.enable = true;
  time.timeZone = lib.mkDefault "America/New_York";
  virtualisation.podman.enable = true;
}
