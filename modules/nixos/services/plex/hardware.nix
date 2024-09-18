{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  plexCfg = config.services.plex;
in
{
  options.services.plex = {
    hardwareAcceleration = lib.mkOption {
      type = types.bool;
      default = false;
      description = lib.mkDoc ''
        Install packages required by Plex to support hardware accelerated
        transcoding.
      '';
    };
  };
  config = lib.mkIf (plexCfg.enable && plexCfg.hardwareAcceleration) {
    hardware.opengl = {
      enable = lib.mkDefault true;
      extraPackages = with pkgs; [
        # Hardware transcoding.
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        libvdpau-va-gl
        vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but can work better for some applications)
        vaapiVdpau
        # HDR tone mapping.
        intel-compute-runtime
        ocl-icd
      ];
    };
  };
}
