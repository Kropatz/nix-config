{ stdenv, nodejs, ... }:
stdenv.mkDerivation rec {
  pname = "gpt-answer";
  version = "1.0";
  src = ./src;
  nativeBuildInputs = [ nodejs ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/answer.js $out/bin/gpt-answer
    chmod +x $out/bin/gpt-answer
  '';
}
