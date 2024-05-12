{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {

      packages.${system} = {

        ctng = pkgs.stdenv.mkDerivation {
          pname = "ct-ng";
          version = "1.26.0";
          src = pkgs.fetchFromGitHub {
            owner = "moritz-meier";
            repo = "crosstool-ng";
            rev = "local";
            hash = "sha256-g9vZQksoTi5bNBlccfUXFqow3lJSG+hlni/Y5sN7mfs=";
          };

          buildInputs = with pkgs; [
            autoconf
            automake
            bison
            flex
            help2man
            libtool
            ncurses
            python3
            texinfo
            unzip
            which
            glibc
            glibc.static
          ];

          configurePhase = ''
            sh ./bootstrap
            sh ./configure --prefix=$out
          '';
        };
      };

      devShells.${system}.default =
        (pkgs.buildFHSEnv {
          name = "ct-ng-fhs";
          targetPkgs = pkgs: [
            self.packages.${system}.default
            pkgs.autoconf
            pkgs.binutils
            pkgs.gcc
            pkgs.glibc
            pkgs.glibc.static
            pkgs.m4
            pkgs.python3
            pkgs.which
          ];

          profile = ''
            unset CC
            unset CXX
            unset LD_LIBRARY_PATH
          '';
          runScript = "bash";
        }).env;
    };
}
