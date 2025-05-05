{ config, lib, ... }:
{
  imports = [
    ../../modules/system/nixos
    ./disks/hrodreptus.nix
    ./disks/titan.nix
    ./networking.nix
  ];

  # TODO: move to 'disks/titan.nix' alongside the pool configuration.
  #
  # Aliases mapping between chassis bay number & device link identifier.
  #
  # Can be reloaded by updating this file & running `udevadm trigger` whenever
  # zpool membership is changed (e.g. when resilvering a failing array).
  environment.etc."zfs/vdev_id.conf".text = ''
    alias bay-1 pci-0000:00:17.0-ata-1
    alias bay-2 pci-0000:00:17.0-ata-2
    alias bay-3 pci-0000:00:17.0-ata-3
    alias bay-4 pci-0000:00:17.0-ata-4
    alias bay-5 pci-0000:00:17.0-ata-6
  '';

  profiles = {
    docs.enable = true;
    server = {
      enable = true;
      media = {
        enable = true;
        jellyfin = true;
        plex = true;
        quicksync = true;
      };
    };
  };

  # FIXME: Find a better place to refactor this out to.
  services.smartd.devices = [
    {
      # NOTE: `DEVICESCAN` finds `/dev/nvme0`, so we should use this (rather
      # than `/dev/disk/by-id`) to make sure it doesn't get monitored twice.
      device = "/dev/nvme0";
      # Inherit default 'smartd' options, but track temperature in 2 degree
      # increments with a log level at 60 C & an alert at 65 C.
      options = lib.concatStringsSep " " (
        config.services.smartd.defaults.shared
        ++ [
          "-W"
          "2,60,65"
        ]
      );
    }
  ];

  # FIXME: Remove this once stuff is done syncing.
  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  fileSystems = {
    "/net/media" = {
      device = "192.168.1.155:/volume1/media";
      fsType = "nfs";
      options = [
        "auto"
        "defaults"
        "nfsvers=4.1"
      ];
    };
  };

  # Hardware survey results.
  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "i915" ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  hardware.cpu.intel.updateMicrocode = true;
}
