{ pkgs, ... }:
# TODO: Source this from a JSON file and write an update script.
#
# cf. The Plex Server 'update.sh'.
{
  gruvbox-material = pkgs.vimUtils.buildVimPlugin {
    name = "gruvbox-material";
    src = pkgs.fetchFromGitHub {
      owner = "sainnhe";
      repo = "gruvbox-material";
      rev = "5cf1ae0742a24c73f29cbffc308c6f5576404e60";
      sha256 = "Gv68wgyrb9RSxRdgPHhvHciQY/umYfgByJ+nA3frKWM=";
    };
  };
}
