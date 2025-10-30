{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "adam-site";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:oberprofis/adams.git";
    ref = "main";
    rev = "6575c418f45aef025d2d89d5b0b4ff4fbdffe298";
  };
  npmDepsHash = "sha256-PRFHBlVIdHfATAAKVKax+bY4o+9czdfl7HjFnKk4KtI=";
  installPhase = ''
    mkdir -p $out
    cp -r ./dist/adams-site/* $out
  '';
}
