let
  pkgs = import ./nixpkgs.nix;
  nixos-generators = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixos-generators";
    rev = "d99d0790fa162cde1c4b2d025e4539ede25742ea";
  }) { inherit pkgs; };
in
with pkgs;

mkShell {
  buildInputs = [
    nixos-generators
  ];
  shellHook = ''
    NIX_PATH=nixpkgs=${pkgs.path}
  '';
}