{ pkgs }:
pkgs.stdenv.mkDerivation {
  name = "hollow-grub-theme";
  src = pkgs.fetchFromGitHub {
    owner = "sergoncano";
    repo = "hollow-knight-grub-theme";
    hash = "sha256-SUy2bQIeUWb/UdQip1ZhBTvXSHJ/LaHhpeK9DGQht6w=";
    rev = "7cef3a2ea25fc2c7ac66d4c9ec1b6a96ca1fd643";
  };
  installPhase = ''
    mkdir -p $out/grub/theme/
    cp -r ./hollow-grub/* $out/grub/theme/
  '';
}
