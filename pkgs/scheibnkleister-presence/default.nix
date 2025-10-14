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
    rev = "82cf49e6a9bc4171e4d8202ebf59d30100fadd7f";
  };

  forceGitDeps = true;
  dontNpmBuild = true;
  npmDepsHash = "sha256-ncjKsjox28t11t3KoIiRlrwO/ISzYmRZ0mfTPO+8XBE=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];
}
