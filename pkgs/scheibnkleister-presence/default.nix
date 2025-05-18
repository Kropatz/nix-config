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
    rev = "34d07540872ae5827b68c7b272a3384480822cff";
  };

  forceGitDeps = true;
  dontNpmBuild = true;
  npmDepsHash = "sha256-ncjKsjox28t11t3KoIiRlrwO/ISzYmRZ0mfTPO+8XBE=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];
}
