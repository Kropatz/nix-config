{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "adam-site";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:oberprofis/adams.git";
    ref = "main";
    rev = "5c6d3af8fc652df254aabf57f5a02214ac6c3518";
  };
  npmDepsHash="sha256-ndpuIqMAitnx0rswYD60l5JhDMdaKH77Qdu7zNgwj/o=";
  installPhase = ''
    mkdir -p $out
    cp -r ./dist/adams-site/* $out
  '';
}
