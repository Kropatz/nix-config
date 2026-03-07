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
    url = "git@github.com:kropatz/kop-fileshare.git";
    ref = "master";
    rev = "3b703425684efce51692a05c3f77f0ad9e4a7eb7";
  };
  vendorHash = "sha256-OQ6rNgOQHrrhE7DT+ulwpWJCDJ4DeJiDzriAu3mfS7I=";

  meta = {
    description = "Simple drag and drop file uploading/sharing website";
    homepage = "https://github.com/Kropatz/kop-fileshare";
    license = lib.licenses.gpl3;
  };
}
