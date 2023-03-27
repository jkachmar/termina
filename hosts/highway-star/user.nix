{config, ...}:
{
  imports = [
    ../../profiles/user/base.nix
    ../../config/user/neovim
    ../../config/user/devtools.nix
  ];

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
