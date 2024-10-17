{ lib, buildNpmPackage, fetchFromGitHub, npm-lockfile-fix }:

buildNpmPackage rec {
  pname = "ente-website";
  version = "1.0.0";

  src = "${(fetchGit {
    url = "git@github.com:oberprofis/ente.git";
    ref = "master";
    rev = "c85e0e152c4f69f5dae5e06ef33360f7ee5fa0c9";
  })}/website/tracker-site";
  npmDepsHash = "sha256-CMgFHB1gSGagE4QWwTIgWLat698vHBnuGk/Qe4HfYnc=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];
  npmFlags = [ "--legacy-peer-deps" ];

  installPhase = ''
    mkdir -p $out
    ls .
    cp -r ./dist/tracker-site/browser/* $out
  '';
}
