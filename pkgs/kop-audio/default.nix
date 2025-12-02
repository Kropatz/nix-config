{
  lib,
  fetchFromGitHub,
  pkg-config,
  libopus,
  libpulseaudio,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kop-audio";
  version = "0.0.1";

  src = fetchGit {
    url = "git@github.com:kropatz/kop-audio.git";
    ref = "master";
    rev = "431a8dd069eb8b5ae56d49ee20652ba2fc1c2969";
  };
  buildInputs = [
    libopus
    libpulseaudio
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  cargoHash = "sha256-NYzy58PR7SMY1nlAWiESraPod2Wam1KVtgr16q9jm60=";

  meta = {
    description = "A voice chat application written in Rust";
    maintainers = [ ];
  };
})
