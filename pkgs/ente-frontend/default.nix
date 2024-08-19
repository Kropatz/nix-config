{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "ente-website";
  version = "1.0.0";

  src = "${(fetchGit {
    url = "git@github.com:oberprofis/ente.git";
    ref = "master";
    rev = "336db364d0a16f8a64abf309f3f1dede6caab2f2";
  })}/website/tracker-site";
  npmDepsHash = "sha256-pNU7Y/73iltMSzGbQwUZWdD7GbIToXMFR5y763Bi50o=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];
  installPhase = ''
    mkdir -p $out
    ls .
    cp -r ./dist/tracker-site/* $out
  '';
}
