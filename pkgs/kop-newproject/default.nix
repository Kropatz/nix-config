{ rustPlatform
, lib
, pkgs
, ...
}:
rustPlatform.buildRustPackage {
  pname = "kop-newproject";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:kropatz/kop-newproject.git";
    ref = "master";
    rev = "b52483c933495715f7ea1530cdd9cfcff6d9c4d8";
  };

  cargoHash = "sha256-FR4H3H+LOF0ZjWIoY5dTU9oKyvwmnWndnkVw3Y42bBg=";
}
