{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  # NOTE: This works in practice, however `sequoia-chameleon-gnupg` doesn't
  # mutate `trustdb.gpg`; this prevents some of the `home-manager` automations
  # from working properly, so it's "better" to stick with `gnupg` (for now).
  sequoia-gnupg-tools = pkgs.symlinkJoin {
    name = "sequoia-gnupg-tools";
    paths = [
      pkgs.gnupg
      unstable.sequoia-chameleon-gnupg
    ];
    postBuild = ''
      mv $out/bin/gpg $out/bin/gnupg
      mv $out/bin/gpgv $out/bin/gnupgv

      mv $out/bin/gpg-sq $out/bin/gpg
      mv $out/bin/gpgv-sq $out/bin/gpgv
    '';
  };
in
{
  home.packages = [ unstable.sequoia-chameleon-gnupg ];
  programs.gpg = {
    enable = true;
    scdaemonSettings = { disable-ccid = true; };
  };
}
