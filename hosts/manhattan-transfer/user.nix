{config, ...}: let
  sshDir = "${config.home.homeDirectory}/.ssh";
  matchFile = "${sshDir}/config.match";
  workFile = "${sshDir}/config.work";
in {
  imports = [
    ../../profiles/user/base.nix
    ../../profiles/user/development.nix
    ../../config/user/ssh
    ../../config/user/ssh/github.nix
  ];

  # XXX: Partial workaround for https://github.com/nix-community/home-manager/issues/2769
  home.file."${matchFile}".text = ''
    Include ${workFile}
  '';
  programs.ssh.extraOptionOverrides."Include" = matchFile;

  # Fixes a bug where fish shell doesn't properly set up the PATH on macOS.
  #
  # FIXME: Looks like a clean reinstall of Nix should fix this now that the
  # installer provides a fish config.
  #
  # cf. https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1299764109
  programs.fish.shellInit = ''
    for p in /usr/local/bin /nix/var/nix/profiles/default/bin ~/.nix-profile/bin
      if not contains $p $fish_user_paths
        set -g fish_user_paths $p $fish_user_paths
      end
    end
  '';
}
