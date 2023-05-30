{
  config,
  pkgs,
  ...
}: let inherit (config.networking) hostname; in
{
  # Import the hardware survey and apply changes/additions here.
  imports = [./survey.nix];

  disko.devices = import ./disks.nix {device = "/dev/nvme0n1";};

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  # XXX: Ensure that the device name matches up with the LUKS container
  # declared by disko!
  boot.initrd.luks.devices.kronos = {
    allowDiscards = true;
    fallbackToPassword = true;
  };

  # ZRAM swap is in-memory, so there's no SSD wear; increase from 1 -> 10.
  boot.kernel.sysctl."vm.swappiness" = 10;
  zramSwap.enable = true;
  zramSwap.writebackDevice = "/dev/zvol/${hostname}/swap-writeback";

  # XXX: Disko doesn't (yet) support marking filesystems as needed for boot.
  fileSystems = {
    "/".neededForBoot = true;
    "/state/root".neededForBoot = true;
    "/secrets".neededForBoot = true;
    "/tmp".neededForBoot = true;
    "/var/log".neededForBoot = true;
  };

  # ZFS requires a stable networking host ID & system machine ID.
  networking.hostId = "b7706107";
  environment.etc."machine-id".source = "/secrets/${hostname}/machine-id";

  services.zfs = {
    trim.enable = true;
    autoScrub.enable = true;
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
    };
  };

  networking.useDHCP = false;
  networking.interfaces = {
    enp86s0.useDHCP = true;
    wlo1.useDHCP = true;
  };
}
