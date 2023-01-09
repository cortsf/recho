{
  description = "recho: print http requests";
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
    let
      overlays = [ haskellNix.overlay
        (final: prev: {
          rechoProject =
            final.haskell-nix.project' {
              src = ./.;
              compiler-nix-name = "ghc925";
              shell.tools = {
                cabal = {};
                hlint = {};
                # haskell-language-server = {};
              };
              shell.buildInputs = with pkgs; [
                nixpkgs-fmt
              ];
            };
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
      flake = pkgs.rechoProject.flake {
      };
    in flake // {
      packages.default = flake.packages."recho:exe:recho";
    });
}
