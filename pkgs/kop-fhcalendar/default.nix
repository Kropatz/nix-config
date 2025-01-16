{ rustPlatform, lib, pkgs, ... }:
rustPlatform.buildRustPackage {
  pname = "kop-fhcalendar";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:kropatz/kop-fhcalendar.git";
    ref = "master";
    rev = "f05d4b3845b6304d22490cf2c759addaf8f8bcd8";
  };

  cargoHash = "sha256-Yo3Xy8oa3KdvttYlYUV0Ut8HMK7BSzqEuIdWAHoDG1M=";
}
