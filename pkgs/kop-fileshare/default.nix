{ buildGoModule, stdenv, pkgs, lib, ... }:
buildGoModule rec {
  pname = "kop-fileshare";
  version = "0.0.1";

  src = fetchGit {
    url = "git@github.com:kropatz/kop-fileshare.git";
    ref = "master";
    rev = "73456c32d3d070d457f95973403ca94bdddea95d";
  };
  vendorHash = "sha256-OQ6rNgOQHrrhE7DT+ulwpWJCDJ4DeJiDzriAu3mfS7I=";

  meta = {
    description = "Simple drag and drop file uploading/sharing website";
    homepage = "https://github.com/Kropatz/kop-fileshare";
    license = lib.licenses.gpl3;
  };
}
