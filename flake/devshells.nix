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
    inherit (pkgs.lib) optionals;
    inherit (pkgs.stdenv.targetPlatform) isDarwin isLinux;
  in
    pkgs.mkShell {
      buildInputs = with pkgs; [
        alejandra
        (writeShellApplication {
          name = "home";
          text = builtins.readFile ../scripts/home;
        })
      ] ++ optionals isDarwin [
        (writeShellApplication {
          name = "darwin";
          text = builtins.readFile ../scripts/darwin;
        })
      ] ++ optionals isLinux [
      ];
    };
in {
  "x86_64-darwin".default = mkShellFor "x86_64" "darwin";
  "aarch64-darwin".default = mkShellFor "aarch64" "darwin";
  "x86_64-linux".default = mkShellFor "x86_64" "linux";
}
