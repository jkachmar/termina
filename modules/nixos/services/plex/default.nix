{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.networking) fqdn;
  cfg = config.services.plex;
in {
  imports = [
    ./hardware.nix
    ./nginx.nix
  ];
  config = lib.mkIf cfg.enable {
    environment.persistence."/state/root".directories = ["/var/lib/plex"];
    systemd.services.plex = {
      after = [
        "network-target.mount"
        "net-media.mount" # Plex must start after NFS media mount is up.
        "var-lib-plex.mount"
      ];
      # Plex _requires_ the NFS media mount, or it should fail as well.
      requires = ["net-media.mount"];
    };
    services.plex = {
      openFirewall = true;
      # TODO: Move this to an overlay.
      package = pkgs.plex.override {
        plexRaw = pkgs.callPackage ./package.nix {};
      };
    };
  };
}
