{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "adam-site";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:oberprofis/adams.git";
    ref = "main";
    rev = "b5af7fe2acf2fcf3b7b115f39c9401d0bf40456d";
  };
  npmDepsHash="sha256-ULxOaEpa2+YS45kh+2xCZMqXQs5bMYhy7J08DsFYE+s=";
  installPhase = ''
    mkdir -p $out
    cp -r ./dist/adams-site/* $out
  '';
}
