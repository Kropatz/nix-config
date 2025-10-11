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
    rev = "0bfd6980fed0e04e6587c1c5cd78a866d152f282";
  };

  forceGitDeps = true;
  dontNpmBuild = true;
  npmDepsHash = "sha256-ncjKsjox28t11t3KoIiRlrwO/ISzYmRZ0mfTPO+8XBE=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];
}
