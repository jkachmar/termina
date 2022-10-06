###############################################
# OS-agnostic Visual Studio Code configuration. #
#################################################
{
  config,
  pkgs,
  unstable,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;

  # Copied from `home-manager` source.
  userDir =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/Application Support/Code/User"
    else "${config.xdg.configHome}/Code/User";
  configFilePath = "${userDir}/settings.json";
  keybindingsFilePath = "${userDir}/keybindings.json";
in {
  programs.vscode = {
    enable = true;
    package = unstable.vscode;
    extensions = unstable.callPackage ./extensions.nix {};
  };

  home.file."${configFilePath}".source =
    mkOutOfStoreSymlink "${config.xdg.configHome}/dotfiles/config/vscode/settings.json";
  home.file."${keybindingsFilePath}".source =
    mkOutOfStoreSymlink "${config.xdg.configHome}/dotfiles/config/vscode/keybindings.json";
}
