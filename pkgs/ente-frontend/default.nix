{ lib, buildNpmPackage, fetchFromGitHub, npm-lockfile-fix }:

buildNpmPackage rec {
  pname = "ente-website";
  version = "1.0.0";

  src = "${(fetchGit {
    url = "git@github.com:oberprofis/ente.git";
    ref = "master";
    rev = "f2743c646ad58e0e9c633de715790761d263df0b";
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
