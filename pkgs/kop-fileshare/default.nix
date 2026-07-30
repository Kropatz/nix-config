{
  buildGoModule,
  stdenv,
  pkgs,
  lib,
  ...
}:
buildGoModule rec {
  pname = "kop-fileshare";
  version = "0.0.1";

  src = fetchGit {
    url = "ssh://git@github.com/kropatz/kop-fileshare.git";
    ref = "master";
    rev = "da8a92c70514b5194564036bc6b9f8c4005c797f";
  };
  vendorHash = "sha256-OQ6rNgOQHrrhE7DT+ulwpWJCDJ4DeJiDzriAu3mfS7I=";

  meta = {
    description = "Simple drag and drop file uploading/sharing website";
    homepage = "https://github.com/Kropatz/kop-fileshare";
    license = lib.licenses.gpl3;
  };
}
