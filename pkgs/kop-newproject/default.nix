{
  rustPlatform,
  lib,
  pkgs,
  ...
}:
rustPlatform.buildRustPackage {
  pname = "kop-newproject";
  version = "1.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "Kropatz";
    repo = "kop-newproject";
    rev = "b93a9c564edd2c44c1dc041ab26a6d3d8281982b";
    hash = "sha256-xZ0g4Y0gN3e5i+5jmWlSFvVSsKXY/4UVj2xxMuB/eXs=";
  };

  cargoHash = "sha256-daR6Mt78QBheEV6Pg6kGUVmU+lgg2eV4/0Sl7UEXUeU=";
}
