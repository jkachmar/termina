{lib, ...}: {
  imports = [
    ./base.nix # Every node inherits from the base profile.
    ../../modules/nixos
    ../../config/system/openssh.nix
    ../../config/system/systemd-boot.nix
  ];

  services.fail2ban.enable = true;
  time.timeZone = lib.mkDefault "America/New_York";
  virtualisation.podman.enable = true;
}
