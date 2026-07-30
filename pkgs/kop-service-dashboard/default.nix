{
  buildGoModule,
  stdenv,
  pkgs,
  lib,
  ...
}:
buildGoModule rec {
  pname = "kop-service-dashboard";
  version = "0.0.1";

  src = fetchGit {
    url = "ssh://gitea@git.kopatz.dev/kopatz/kop-service-dashboard.git";
    ref = "master";
    rev = "d49f95dbcb18710d0f4beb493f112386217be8f3";
  };
  vendorHash = null;

  meta = {
    description = "Kop service dashboard";
    license = lib.licenses.gpl3;
  };
}
