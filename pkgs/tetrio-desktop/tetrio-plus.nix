{ lib, stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "tetrio-plus";
  version = "0.25.3";

  src = fetchzip {
    url = "https://gitlab.com/UniQMG/tetrio-plus/-/jobs/6465395934/artifacts/raw/app.asar.zip";
    hash = "sha256-24AD63YEypK7XUW6QnqJt56cUExIMrA2WgDi8jS5IFE=";
  };

  installPhase = ''
    runHook preInstall

    install app.asar $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "TETR.IO customization toolkit";
    homepage = "https://gitlab.com/UniQMG/tetrio-plus";
    license = licenses.mit;
    maintainers = with maintainers; [ huantian ];
    platforms = [ "x86_64-linux" ];
  };
}
