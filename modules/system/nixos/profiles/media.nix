{ config, lib, pkgs, ... }:
let
  jellyCfg = config.services.jellyfin;
  plexCfg = config.services.plex;
  cfg = config.profiles.server.media;
in
{
  options.profiles.server.media = {
    enable = lib.mkEnableOption "media server profile";
    quicksync = lib.mkEnableOption "quicksync codec support";
    jellyfin = lib.mkEnableOption "jellyfin support";
    plex = lib.mkEnableOption "plex support";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      users.groups.media.gid = 1010;

    })
    (lib.mkIf (cfg.enable && cfg.jellyfin) {
      services.jellyfin.enable = true;
      users.users.${jellyCfg.user}.extraGroups = [ "media" ];
      # FIXME: reverse proxy these behind nginx & close the ports off.
      # NOTE: These can be changed in the web UI.
      networking.firewall = {
        allowedTCPPorts = [
          8096
          8920
        ];
        allowedUDPPorts = [
          1900
          7359
        ];
      };
    })

    (lib.mkIf (cfg.enable && cfg.plex) {
      services.plex.enable = true;
      users.users.${plexCfg.user}.extraGroups = [ "media" ];
      networking.firewall = {
        allowedTCPPorts = [
          32400
          3005
          8324
          32469
        ];
        allowedUDPPorts = [
          1900
          5353
          32410
          32412
          32413
          32414
        ];
      };
    })
    (lib.mkIf (cfg.enable && cfg.quicksync) {
      systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
      users.users.${jellyCfg.user}.extraGroups = [ "render" "video" ];

      systemd.services.plex.environment.LIBVA_DRIVER_NAME = "iHD";
      users.users.${plexCfg.user}.extraGroups = [ "render" "video" ];

      hardware.enableAllFirmware = true;
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          # Hardware transcoding
          intel-media-driver # LIBVA_DRIVER_NAME=iHD
          vpl-gpu-rt # QSV on 11th gen or newer
          libvdpau-va-gl
          vaapiVdpau
          # HDR tone mapping & subtitle burn-in
          intel-compute-runtime # OpenCL filter support
          intel-ocl # OpenCL support
        ];
      };
    })
  ];
}
