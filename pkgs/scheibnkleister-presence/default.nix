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
    rev = "b31f6954fc0cf44db4f4ccdab5ae1d4611de1d31";
  };

  forceGitDeps = true;
  dontNpmBuild = true;
  npmDepsHash = "sha256-ncjKsjox28t11t3KoIiRlrwO/ISzYmRZ0mfTPO+8XBE=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];
}
