{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "adam-site";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:oberprofis/adams.git";
    ref = "main";
    rev = "4f5ef5db79878e0bc244b71a979bb14e6b6177d6";
  };
  npmDepsHash="sha256-ndpuIqMAitnx0rswYD60l5JhDMdaKH77Qdu7zNgwj/o=";
  installPhase = ''
    mkdir -p $out
    cp -r ./dist/adams-site/* $out
  '';
}
