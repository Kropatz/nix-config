{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "adam-site";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:oberprofis/adams.git";
    ref = "main";
    rev = "95d7f5d21f129949c75bd23ee5edbf84595ceec3";
  };
  npmDepsHash="sha256-PRFHBlVIdHfATAAKVKax+bY4o+9czdfl7HjFnKk4KtI=";
  installPhase = ''
    mkdir -p $out
    cp -r ./dist/adams-site/* $out
  '';
}
