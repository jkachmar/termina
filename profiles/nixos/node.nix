{lib, ...}: {
  imports = [
    ../../modules/nixos/sudo-cmds.nix
    ../../config/system/fail2ban.nix
    ../../config/system/openssh.nix
    ../../config/system/systemd-boot.nix
    ../../config/system/virtualization.nix
  ];

  time.timeZone = lib.mkDefault "America/New_York";
}
