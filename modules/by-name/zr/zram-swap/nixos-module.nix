{ config, lib, ... }:
let
  cfg = config.zramSwap;
in
{
  # ZRAM swap is in-memory, so we can tune a few things differently.
  #
  # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
  boot.kernel.sysctl = lib.mkIf cfg.enable {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  zramSwap = {
    memoryPercent = lib.mkDefault 50;
    # NOTE: This _must_ be higher than disk-based swap priority, otherwise
    # 'zram'-based swap is pretty much useless.
    priority = lib.mkDefault 10;
  };
}
