{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "adam-site";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:oberprofis/adams.git";
    ref = "main";
    rev = "001e9feb4d53f3046068f1bb88c7386b6c6f7f58";
  };
  npmDepsHash="sha256-PRFHBlVIdHfATAAKVKax+bY4o+9czdfl7HjFnKk4KtI=";
  installPhase = ''
    mkdir -p $out
    cp -r ./dist/adams-site/* $out
  '';
}
