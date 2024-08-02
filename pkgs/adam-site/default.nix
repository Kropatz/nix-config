{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "adam-site";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:oberprofis/adams.git";
    ref = "main";
    rev = "921d3deff4d4777b6948e642ae5f27d43b1e2e26";
  };
  npmDepsHash="sha256-PRFHBlVIdHfATAAKVKax+bY4o+9czdfl7HjFnKk4KtI=";
  installPhase = ''
    mkdir -p $out
    cp -r ./dist/adams-site/* $out
  '';
}
