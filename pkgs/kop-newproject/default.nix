{ rustPlatform, lib, pkgs, ... }:
rustPlatform.buildRustPackage {
  pname = "kop-newproject";
  version = "1.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "Kropatz";
    repo = "kop-newproject";
    rev = "0c1e64c0ab8d5b81a12562665b903240a02e315a";
    hash = "sha256-Va6q9aDbX5Kag96WK1XAhDMb7VDzZzfp24t89C9oRuY=";
  };

  cargoHash = "sha256-daR6Mt78QBheEV6Pg6kGUVmU+lgg2eV4/0Sl7UEXUeU=";
}
