{ rustPlatform
, lib
, pkgs
, ...
}:
rustPlatform.buildRustPackage {
  pname = "kop-fhcalendar";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:kropatz/kop-fhcalendar.git";
    ref = "master";
    rev = "c765949de30eeea99241e9f2ba4d9b5d30c43a1b";
  };

  cargoHash = "sha256-IrTBLJ3bAe+xveZa5eEz7K51zsM+EQokQNR//1ZHbBk=";
}
