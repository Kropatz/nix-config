{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "adam-site";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:oberprofis/adams.git";
    ref = "main";
    rev = "2bb42879fc9cf94217b0759b5c09a63ff69f5bac";
  };
  npmDepsHash="sha256-PRFHBlVIdHfATAAKVKax+bY4o+9czdfl7HjFnKk4KtI=";
  installPhase = ''
    mkdir -p $out
    cp -r ./dist/adams-site/* $out
  '';
}
