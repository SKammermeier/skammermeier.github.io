{
  description = "Personal website";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {self, nixpkgs, utils, ...}: utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
    in   rec {

    packages = rec {
          published = pkgs.stdenv.mkDerivation {
            name = "skammermeier.github.io";
            src = self;

            buildPhase = ''
              ${pkgs.hugo}/bin/hugo
            '';

            installPhase = ''
              cp -r public $out
              cp -r themes $out
              cp hugo.toml $out
            '';
          };

          drafts = published.overrideAttrs (old: {
            buildPhase = ''
              ${pkgs.hugo}/bin/hugo -D
            '';
          });

          default = drafts;
        };

    apps.default = utils.lib.mkApp {
      drv = pkgs.writeShellScriptBin "pages" "${pkgs.python312}/bin/python3 -m http.server 8000 -d ${packages.default}";
    };

    devShells.default = pkgs.mkShellNoCC {
          buildInputs = [ pkgs.hugo ];
    };
  });
}
