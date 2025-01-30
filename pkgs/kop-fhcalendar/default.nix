{ rustPlatform, lib, pkgs, ... }:
rustPlatform.buildRustPackage {
  pname = "kop-fhcalendar";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:kropatz/kop-fhcalendar.git";
    ref = "master";
    rev = "328b43766fe4fe3b352a23f160de6bc96a3aee58";
  };

  cargoHash = "sha256-Yo3Xy8oa3KdvttYlYUV0Ut8HMK7BSzqEuIdWAHoDG1M=";
}
