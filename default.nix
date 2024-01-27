{ pkgs ? import <nixpkgs> {} }:

let
  cosmocc = pkgs.fetchzip {
    url = "https://github.com/jart/cosmopolitan/releases/download/" +
      "3.2.4/cosmocc-3.2.4.zip";
    hash = "sha256-cuJAI+q6fmne0C6QTtfvu6WCBuLkgabCCRcxbMhR9tM=";
    stripRoot = false;
  };

  cosmo-ncurses = pkgs.stdenv.mkDerivation rec {
    pname = "cosmopolitan";
    version = "3.2.4";

    src = pkgs.fetchFromGitHub {
      owner = "jart";
      repo = "cosmopolitan";
      rev = version;
      hash = "sha256-DWacTVHZQ1yKpH+moSkf5wTs9TVaeuVaRcrZKWFVujw=";
    };

    dontFixup = true;

    buildInputs = [ pkgs.unzip ];
    makeFlags = [
      "COSMOCC=${cosmocc}"
      "o//third_party/ncurses/ncurses.a"
    ];

    preBuild = ''
      for f in build/bootstrap/*.com; do
        $f --assimilate
      done
    '';

    installPhase = ''
      mkdir -p $out/{include,lib}
      cp third_party/ncurses/*.h $out/include
      cp o/third_party/ncurses/ncurses.a $out/lib
    '';
  };

  openbsd-mg = pkgs.fetchFromGitHub {
    owner = "openbsd";
    repo = "src";
    rev = "16beb55006f170e70eb874084029ccc0ed4470b4";
    sha256 = "sha256-B6ENfWZTzfCsE8xAO2F0RTwZD+iVUVwNDSDuvjZ2ycA=";
    sparseCheckout = [
      "/usr.bin/mg/"
      "/sys/sys/"
    ];
  };
in
pkgs.stdenv.mkDerivation {
  name = "yamg";
  src = builtins.fetchGit ./.;

  buildInputs = [ cosmocc ];

  postUnpack = ''
    pushd $sourceRoot
    mkdir -p src/usr.bin
    ln -s ${openbsd-mg}/sys src/sys
    cp -r ${openbsd-mg}/usr.bin/mg src/usr.bin
    chmod -R +w src/usr.bin
    popd
  '';

  patches = [ "pledge.patch" ];

  makeFlags = [
    "COSMO_NCURSES_INC=${cosmo-ncurses}/include"
    "COSMO_NCURSES_LIB=${cosmo-ncurses}/lib/ncurses.a"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp mg $out/bin
  '';
}
