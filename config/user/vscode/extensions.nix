{
  buildPlatform,
  fetchurl,
  lib,
  vscode-extensions,
  vscode-utils,
}: let
  inherit (buildPlatform) system;
  inherit (vscode-utils) buildVscodeMarketplaceExtension;

  sources = builtins.fromJSON (builtins.readFile ./sources.json);
  extensions = lib.lists.forEach sources (
    source: let
      hasPlatforms = builtins.hasAttr "platforms" source.src;
      args =
        if hasPlatforms
        then ({inherit (source.src) name;} // source.src.platforms.${system})
        else source.src;
      vsix = fetchurl args;
      mktplcRef = {inherit (source) name publisher version;};
    in
      buildVscodeMarketplaceExtension {
        inherit mktplcRef vsix;
      }
  );
in
  extensions ++ []
