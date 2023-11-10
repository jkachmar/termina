{
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) hostName;
in {
  # Import the hardware survey and apply changes/additions here.
  imports = [
    ./survey.nix
    (import ./disks.nix {device = "/dev/nvme0n1";})
  ];

  boot.initrd = {
    kernelModules = [
      # Needed for automatic LUKS unlock.
      "usb_storage"
    ];
  };
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  # ZRAM swap is in-memory, so there's no SSD wear; increase from 1 -> 10.
  boot.kernel.sysctl."vm.swappiness" = 10;
  zramSwap = {
    enable = true;
    memoryPercent = 25; # 16G ought to be enough swap space for anybody.
  };

  # XXX: Disko doesn't (yet) support marking filesystems as needed for boot.
  fileSystems = {
    "/".neededForBoot = true;
    "/state/root".neededForBoot = true;
    "/secrets".neededForBoot = true;
    "/tmp".neededForBoot = true;
    "/var/log".neededForBoot = true;

    # NFS mounts (to the synology) cannot & should not be managed by disko.
    #
    # NOTE: [nfs-rpcbind-workaround]
    "/net/downloads" = {
      device = "192.168.1.155:/volume1/downloads";
      fsType = "nfs";
      options = [ "auto" "defaults" "nfsvers=4.1" ];
    };
    "/net/media" = {
      device = "192.168.1.155:/volume1/media";
      fsType = "nfs";
      options = [ "auto" "defaults" "nfsvers=4.1" ];
    };
  };

  # NOTE: [nfs-rpcbind-workaround]
  #
  # Filesystem declarations with 'fsType = "nfs"' will fail to mount without
  # the following configuration enabled.
  #
  # cf. https://github.com/NixOS/nixpkgs/issues/76671#issuecomment-1399044941
  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  # Enable kernel same-page merging; this allows KVM guests to share identical
  # memory pages, potentially reducing overall memory footprint for guests
  # using identical (or even similar) guest operating systems.
  hardware.ksm.enable = true;
  systemd.tmpfiles.rules = [
    # 'pages_to_scan' defaults to 100, which is 400kb at the default page size.
    #
    # SUSE's docs recommend bumping this to 1000 pages (4mb) so let's do that.
    #
    # cf. https://documentation.suse.com/sles/15-SP1/single-html/SLES-vt-best-practices/#sec-vt-best-perf-ksm
    "w /sys/kernel/mm/ksm/pages_to_scan 644 root root - 1000"
    # 'sleep_millisecs' defaults to '20' which can seriously overtax the CPU.
    #
    # SUSE's docs recommend setting this to >1000; let's start at 2 seconds.
    "w /sys/kernel/mm/ksm/sleep_millisecs 644 root root - 2000"
    # Do _not_ merge across NUMA nodes, why is this on by default?
    "w /sys/kernel/mm/ksm/merge_across_nodes 644 root root - 0"
  ];

  # ZFS requires a stable networking host ID & system machine ID.
  networking.hostId = "b7706107";
  environment.etc."machine-id".source = "/secrets/${hostName}/machine-id";

  services.zfs = {
    trim.enable = true;
    autoScrub.enable = true;
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
    };
  };
}
