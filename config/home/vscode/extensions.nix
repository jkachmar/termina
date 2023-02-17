{ lib, vscode-extensions, vscode-utils }:

let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
  extensions = lib.lists.forEach sources (source: buildVscodeMarketplaceExtension {
    mktplcRef = {
      inherit (source) name publisher version sha256;
    };
  });
in
  extensions ++ [];

