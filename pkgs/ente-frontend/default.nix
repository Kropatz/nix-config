{ lib, buildNpmPackage, fetchFromGitHub, npm-lockfile-fix }:

buildNpmPackage rec {
  pname = "ente-website";
  version = "1.0.0";

  src = "${(fetchGit {
    url = "git@github.com:oberprofis/ente.git";
    ref = "master";
    rev = "cb63e1e20fd9fde401fa9d3f09b36c572b17ff34";
  })}/website/tracker-site";
  npmDepsHash = "sha256-fYTRhIU+8pdIm3wC5wJRcDUhgN3d+mmvfmVzuu0pjLQ=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  #npmPackFlags = [ "--ignore-scripts" ];
  #npmFlags = [ "--legacy-peer-deps" ];

  installPhase = ''
    mkdir -p $out
    ls .
    cp -r ./dist/tracker-site/browser/* $out
  '';
}
