{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  ...
}:
buildNpmPackage rec {
  pname = "scheibnkleister-presence";
  version = "0.0.1";

  src = fetchGit {
    url = "git@github.com:oberprofis/scheibnkleister-presence.git";
    ref = "master";
    rev = "28923f9e6de59f54788b4976f523bb908f90dcba";
  };

  forceGitDeps = true;
  dontNpmBuild = true;
  npmDepsHash = "sha256-2DlMY2kEBMQUs1LTrZJgT9J2itPlhmACLu2sJ6HBGq8=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];
}
