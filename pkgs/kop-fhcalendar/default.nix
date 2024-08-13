{ rustPlatform, lib, pkgs, ... }:
rustPlatform.buildRustPackage {
  pname = "kop-fhcalendar";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:kropatz/kop-fhcalendar.git";
    ref = "master";
    rev = "d1f1eca9b38a47cee18023440fefde7e3e01ccc4";
  };

  cargoHash = "sha256-yx71/6UqD5RDsISeXhQj/zuyLW2Eit32pHYyZBExauE=";
}
