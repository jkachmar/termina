{ config, ... }:
let
  cfg = config.boot.initrd.systemd;
in
{
  config = {
    boot = {
      initrd.systemd.enable = true;
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          enable = true;
          editor = true;
        };
        timeout = 10;
      };
    };
  };
}
