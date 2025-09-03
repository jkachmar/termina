{ config, lib, ... }:
let
  cfg = config.profiles.server;
in
{
  options.profiles.server.enable = lib.mkEnableOption "server profile";

  config = lib.mkIf cfg.enable {
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

    networking = {
      firewall.enable = lib.mkDefault true;
      nftables.enable = lib.mkDefault true;
    };

    services = {
      fail2ban.enable = lib.mkDefault true;
      openssh.enable = lib.mkDefault true;
      smartd.enable = lib.mkDefault true;
    };

    zramSwap.enable = true;
  };
}
