{
  utils,
  macosPkgs,
  nixosPkgs,
  ...
}: {
  "x86_64-darwin".default = let
    pkgs = utils.mkPkgsFor "x86_64-darwin" macosPkgs;
  in
    pkgs.mkShell {
      buildInputs = with pkgs; [
        alejandra
      ];
    };
  "aarch64-darwin".default = let
    pkgs = utils.mkPkgsFor "aarch64-darwin" macosPkgs;
  in
    pkgs.mkShell {
      buildInputs = with pkgs; [
        alejandra
      ];
    };

  "x86_64-linux".default = let
    pkgs = utils.mkPkgsFor "x86_64-linux" nixosPkgs;
  in
    pkgs.mkShell {
      buildInputs = with pkgs; [
        alejandra
      ];
    };
}
