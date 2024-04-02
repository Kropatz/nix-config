{ lib, stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "tetrio-plus";
  version = "0.25.3";

  src = fetchzip {
    url = "https://gitlab.com/UniQMG/tetrio-plus/-/jobs/6517560474/artifacts/raw/app.asar.zip";
    hash = "sha256-I7UvljloJyKrYpSuQ9V1ySSXKhYeJGDpex/K0R3iuCc=";
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
