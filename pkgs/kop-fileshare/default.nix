{
  buildGoModule,
  stdenv,
  pkgs,
  lib,
  ...
}:
buildGoModule rec {
  pname = "kop-fileshare";
  version = "0.0.2";

  src = fetchGit {
    url = "ssh://git@github.com/kropatz/kop-fileshare.git";
    ref = "master";
    rev = "e995ddd606f277559f4fe0c4c9e0e90ff3afe5ba";
  };
  vendorHash = "sha256-OQ6rNgOQHrrhE7DT+ulwpWJCDJ4DeJiDzriAu3mfS7I=";

  meta = {
    description = "Simple drag and drop file uploading/sharing website";
    homepage = "https://github.com/Kropatz/kop-fileshare";
    license = lib.licenses.gpl3;
  };
}
