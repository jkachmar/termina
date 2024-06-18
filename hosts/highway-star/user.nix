{ config, ... }:
{
  imports = [
    ../../profiles/user/base.nix
    ../../profiles/user/development.nix
    ../../config/user/gpg/linux.nix
  ];

  # XXX: Okay so this makes sense for work stuff but sometimes i also want to
  # pull stuff down from GitHub; maybe i  should switch to one of those things
  # where it changes git config based on the directory i'm in?
  programs.git.userEmail = "jkachmar@groq.com";

  # NOTE: Works w/ the tmux config (below) to set the Okta auth stuff.
  programs.bash.bashrcExtra = ''
    if [ -n "$TMUX" ]; then
      function refresh () {
        eval $(tmux showenv -s)
      }
    else
      function refresh () { :; }
    fi
  '';

  programs.starship.settings = {
    # XXX: Removes trailing space.
    gcloud.symbol = "☁️ ";
    hostname = {
      disabled = false;
      format = "[$hostname-dev-vm](bold red) in ";
      style = "bold green";
    };
  };

  programs.tmux.extraConfig = ''
    set -g update-environment "SFT_AUTH_SOCK SSH_AUTH_SOCK SSH_CONNECTION DISPLAY"
    set -g mouse on
  '';
}
