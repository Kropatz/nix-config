{ rustPlatform, lib, pkgs, ... }:
rustPlatform.buildRustPackage {
  pname = "kop-fhcalendar";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:kropatz/kop-fhcalendar.git";
    ref = "master";
    rev = "f1c9cea0874cdd8465c38b10f73f73272e9d4233";
  };

  cargoHash = "sha256-N6BWKumzKWXmAbg3GxiCS70yRg8i+TrYu6T8u6nuHdY=";
}
