{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "adam-site";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:oberprofis/adams.git";
    ref = "main";
    rev = "0d1d5003bd5681c5dbe2ad12ed1ef7e56bb4c197";
  };
  npmDepsHash="sha256-ndpuIqMAitnx0rswYD60l5JhDMdaKH77Qdu7zNgwj/o=";
  installPhase = ''
    mkdir -p $out
    cp -r ./dist/adams-site/* $out
  '';
}
