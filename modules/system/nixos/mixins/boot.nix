{ lib, ... }:
{
  # Always clear 'tmp' on boot.
  boot = {
    tmp = {
      cleanOnBoot = lib.mkDefault true;
      useTmpfs = lib.mkDefault true;
      tmpfsSize = lib.mkDefault "8G";
    };

    loader = {
      # Use the systemd-boot EFI boot loader by default.
      systemd-boot = {
        enable = lib.mkDefault true;
        # Don't keep more than 32 old configurations, to keep the '/boot'
        # partition from filling up.
        configurationLimit = lib.mkDefault 32;
      };

      efi.canTouchEfiVariables = lib.mkDefault true;
    };
  };
}
