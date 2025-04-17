{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.docs;
in
{
  options.profiles.docs.enable = (lib.mkEnableOption "system docs profile") // {
    default = true;
  };
  config = lib.mkIf cfg.enable {
    documentation = {
      # Install documentation from all packages in `environment.systemPackages`.
      enable = true;
      # Enable documentation in packages' `/share/doc`.
      doc.enable = true;
      # Enable manpages.
      man.enable = true;
    };
    environment.systemPackages = with pkgs; [
      # _All_ the manpages
      man-pages
      man-pages-posix
      # A fast documentation viewer for nix.
      manix
      # Parse formatted man pages & man page source from most flavors of UNIX
      # and convert them to HTML, ASCII, TkMan, DocBook, and other formats.
      rman
    ];
  };
}
