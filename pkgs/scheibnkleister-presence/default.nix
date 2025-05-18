{ buildNpmPackage
, fetchFromGitHub
, lib
, ...
}:
buildNpmPackage rec {
  pname = "scheibnkleister-presence";
  version = "0.0.1";

  src = fetchGit {
    url = "git@github.com:oberprofis/scheibnkleister-presence.git";
    ref = "master";
    rev = "c3157f9be51e49a4fc102d141ab562d38645ffcf";
  };

  forceGitDeps = true;
  dontNpmBuild = true;
  npmDepsHash = "sha256-ncjKsjox28t11t3KoIiRlrwO/ISzYmRZ0mfTPO+8XBE=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];
}
