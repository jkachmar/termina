{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  sequoia-gnupg-tools = pkgs.symlinkJoin {
    name = "sequoia-gnupg-tools";
    paths = [
      pkgs.gnupg
      unstable.sequoia-chameleon-gnupg
    ];
    postBuild = ''
      mv $out/bin/gpg-sq $out/bin/gpg
      mv $out/bin/gpgv-sq $out/bin/gpgv
    '';
  };
in
{
  programs.gpg = {
    enable = true;
    package = sequoia-gnupg-tools;
    scdaemonSettings = { disable-ccid = true; };
  };
}
