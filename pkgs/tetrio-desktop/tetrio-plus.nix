{ lib, stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "tetrio-plus";
  version = "0.25.3";

  src = fetchzip {
    url = "https://gitlab.com/UniQMG/tetrio-plus/-/jobs/6734605389/artifacts/raw/tetrio-plus_v0.27.2_for_desktop_v9.asar.zip";
    hash = "sha256-+5jXhJwltw426eWU1yR4jxXlOm/etuJKzfeoXSetMws=";
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
