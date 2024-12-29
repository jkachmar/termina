{ inputs, ... }:
{
  imports = [
    ./fonts.nix
    ./gpg.nix
    ./home.nix
    ./ssh.nix
    ./utils.nix
    ./vcs.nix
  ];
  # Set the default 'home-manager' state version globally;
  home.stateVersion = "24.11";
}
