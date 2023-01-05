{
  utils,
  macosPkgs,
  nixosPkgs,
  ...
}: let
  mkShellFor = arch: os: let
    pkgset =
      if os == "darwin"
      then macosPkgs
      else nixosPkgs;
    pkgs = utils.mkPkgsFor "${arch}-${os}" pkgset;
  in
    pkgs.mkShell {
      buildInputs = with pkgs; [
        alejandra
        (writeShellApplication {
          name = "home";
          text = builtins.readFile ../scripts/home;
        })
      ];
    };
in {
  "x86_64-darwin".default = mkShellFor "x86_64" "darwin";
  "aarch64-darwin".default = mkShellFor "aarch64" "darwin";
  "x86_64-linux".default = mkShellFor "x86_64" "linux";
}
