{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "adam-site";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:oberprofis/adams.git";
    ref = "main";
    rev = "68fa8392335a462634d4bb886344762592c8d566";
  };
  npmDepsHash="sha256-ULxOaEpa2+YS45kh+2xCZMqXQs5bMYhy7J08DsFYE+s=";
  installPhase = ''
    mkdir -p $out
    cp -r ./dist/adams-site/* $out
  '';
}
