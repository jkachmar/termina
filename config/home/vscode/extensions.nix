{
  lib,
  vscode-extensions,
  vscode-utils,
  ...
}:
# TODO: Update this with a script or something.
#
# cf. https://github.com/NixOS/nixpkgs/blob/634141959076a8ab69ca2cca0f266852256d79ee/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;

  kahole.magit = buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "magit";
      publisher = "kahole";
      version = "0.6.30";
      sha256 = "492xPIc3MBvtI9jO7xr6p6WLyOAdhD3l2MT7Seyxm2g=";
    };
  };

  ms-vscode-remote.remote-ssh = buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "remote-ssh";
      publisher = "ms-vscode-remote";
      version = "0.85.2022071315";
      sha256 = "kcqN8Ym1cyTT+P8h0nTq1j/GroMWOI4iPeLwvbkQrKQ=";
    };
  };

  tamasfe.even-better-toml = buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "even-better-toml";
      publisher = "tamasfe";
      version = "0.17.1";
      sha256 = "EoUtlLZfAZ5W1b1cWwTNuBdY+h0QmMG9L3fvIfJsEQk=";
    };
  };

  trond-snekvik.simple-rst = buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "simple-rst";
      publisher = "trond-snekvik";
      version = "1.5.2";
      sha256 = "pV7/S8kkDIbhD2K5P2TA8E0pM4F8gsFIlc+4FIheBbc=";
    };
  };
in
  [
    kahole.magit
    ms-vscode-remote.remote-ssh
    tamasfe.even-better-toml
    trond-snekvik.simple-rst
  ]
  ++ (with vscode-extensions; [
    bbenoist.nix
    gruntfuggly.todo-tree
    timonwong.shellcheck
    # NOTE: Fix has been merged but not propagated to 'unstable' yet.
    #
    # cf. https://github.com/NixOS/nixpkgs/issues/176697
    # vadimcn.vscode-lldb
    vscodevim.vim
  ])
