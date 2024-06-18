{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  cfg = config.programs.vscode;
  inherit (config.lib.file) mkOutOfStoreSymlink;

  # Copied from `home-manager` source.
  userDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/Code/User"
    else
      "${config.xdg.configHome}/Code/User";
  configFilePath = "${userDir}/settings.json";
  keybindingsFilePath = "${userDir}/keybindings.json";
in
lib.mkIf cfg.enable {
  programs.vscode = {
    package = unstable.vscode;
    extensions = unstable.callPackage ./extensions.nix { };
  };

  # XXX: It's important that all systems store dotfiles at the same location.
  home.file."${
    configFilePath
  }".source = mkOutOfStoreSymlink "${config.xdg.configHome}/dotfiles/modules/user/vscode/settings.json";
  home.file."${
    keybindingsFilePath
  }".source = mkOutOfStoreSymlink "${config.xdg.configHome}/dotfiles/modules/user/vscode/keybindings.json";
}
