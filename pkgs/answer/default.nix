{ stdenv, nodejs, ... }:
stdenv.mkDerivation rec {
  pname = "answer";
  version = "1.0";
  src = ./src;
  nativeBuildInputs = [ nodejs ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/answer.js $out/bin/answer
    chmod +x $out/bin/answer
  '';
}
